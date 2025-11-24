extends Node2D

var rock_small = preload("res://Objects/rock_small.tscn")
var rock_medium = preload("res://Objects/rock_medium.tscn")
var rock_large = preload("res://Objects/rock_large.tscn")

var grid_cell_size = 100.0
var spatial_grid = {}
var chunks := {} # { Vector2i : { "rocks": [Node2D], "clusters": [Dict] } }
var cluster_centers_global: Array = []
var density_noise: FastNoiseLite

const CLEAR_RADIUS = 300.0
const MIN_ROCK_DISTANCE = 25.0
const CLUSTER_SPREAD = 150.0
const MIN_CLUSTER_SEPARATION = 400.0
const REQUIRED_PLAYER_CORRIDOR = 80.0
const CHUNK_SIZE = 512.0
const ACTIVE_RADIUS_CHUNKS = 3
const CULL_RADIUS_CHUNKS = 5
const CHUNK_SPARSE_ROCK_COUNT = 15
const CHUNK_CLUSTER_SAMPLE_GRID = 128.0
const ROCKS_PER_DENSE_CLUSTER = 35
const ROCKS_PER_MEDIUM_CLUSTER = 20
const ROCK_SIZES = {
	"small": 6.0,
	"medium": 12.0,
	"large": 18.0
}
func _ready():
	setup_noise_generators()
	_update_chunks(true)

func _process(_delta: float) -> void:
	_update_chunks()

func setup_noise_generators():
	var seed_value = Time.get_ticks_msec()

	print("Rock Manager: Generating cluster-based terrain with seed: ", seed_value)
	density_noise = FastNoiseLite.new()
	density_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	density_noise.seed = seed_value
	density_noise.frequency = 0.005
	density_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	density_noise.fractal_octaves = 3

func generate_rocks():
	pass


func is_in_spawn_passage(pos: Vector2) -> bool:
	var distance = pos.length()
	if distance < CLEAR_RADIUS or distance > PASSAGE_MIN_LENGTH:
		return false
	var angle_to_pos = atan2(pos.y, pos.x)
	if angle_to_pos < 0:
		angle_to_pos += TAU
	for i in range(NUM_PASSAGES):
		var passage_angle = (TAU / NUM_PASSAGES) * i
		var angle_diff = abs(angle_to_pos - passage_angle)
		if angle_diff > PI:
			angle_diff = TAU - angle_diff
		var perpendicular_distance = distance * sin(angle_diff)
		if perpendicular_distance < PASSAGE_WIDTH / 2.0:
			return true
	return false

const NUM_PASSAGES = 8
const PASSAGE_WIDTH = 100.0
const PASSAGE_MIN_LENGTH = 600.0
const ROCK_WEIGHTS = {"small": 0.5, "medium": 0.35, "large": 0.15}

func choose_rock_type() -> String:
	var r = randf()
	if r < ROCK_WEIGHTS.small:
		return "small"
	elif r < ROCK_WEIGHTS.small + ROCK_WEIGHTS.medium:
		return "medium"
	return "large"

func spawn_rock(rock_type: String, pos: Vector2):
	var rock_scene
	match rock_type:
		"small": rock_scene = rock_small
		"medium": rock_scene = rock_medium
		"large": rock_scene = rock_large
	var rock = rock_scene.instantiate()
	rock.position = pos
	rock.rotation = randf() * TAU
	add_child(rock)

func is_position_valid(pos: Vector2, radius: float) -> bool:
	var nearby_rocks = get_nearby_rocks(pos)

	for rock_data in nearby_rocks:
		var rock_pos = rock_data.position
		var rock_radius = rock_data.radius
		var min_distance = radius + rock_radius + MIN_ROCK_DISTANCE

		if pos.distance_to(rock_pos) < min_distance:
			return false

	return true

func add_to_spatial_grid(pos: Vector2, radius: float):
	var grid_key = get_grid_key(pos)

	if not spatial_grid.has(grid_key):
		spatial_grid[grid_key] = []

	spatial_grid[grid_key].append({
		"position": pos,
		"radius": radius
	})

func get_nearby_rocks(pos: Vector2) -> Array:
	var nearby = []

	for x in range(-1, 2):
		for y in range(-1, 2):
			var check_pos = pos + Vector2(x * grid_cell_size, y * grid_cell_size)
			var grid_key = get_grid_key(check_pos)

			if spatial_grid.has(grid_key):
				nearby.append_array(spatial_grid[grid_key])

	return nearby

func get_grid_key(pos: Vector2) -> Vector2i:
	return Vector2i(
		int(pos.x / grid_cell_size),
		int(pos.y / grid_cell_size)
	)

func clear_rocks():
	for chunk_data in chunks.values():
		for rock in chunk_data.rocks:
			if is_instance_valid(rock):
				rock.queue_free()
	chunks.clear()
	cluster_centers_global.clear()
	spatial_grid.clear()

func regenerate_rocks():
	setup_noise_generators()
	clear_rocks()
	_update_chunks(true)

func can_place_cluster(pos: Vector2) -> bool:
	var required_center_distance = max(MIN_CLUSTER_SEPARATION, (CLUSTER_SPREAD * 2.0) + REQUIRED_PLAYER_CORRIDOR)
	for c in cluster_centers_global:
		if pos.distance_to(c.pos) < required_center_distance:
			return false
	return true

func _update_chunks(_force: bool = false) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var player_chunk = _world_to_chunk(player.global_position)
	for cx in range(player_chunk.x - ACTIVE_RADIUS_CHUNKS, player_chunk.x + ACTIVE_RADIUS_CHUNKS + 1):
		for cy in range(player_chunk.y - ACTIVE_RADIUS_CHUNKS, player_chunk.y + ACTIVE_RADIUS_CHUNKS + 1):
			var coord = Vector2i(cx, cy)
			if not chunks.has(coord):
				_generate_chunk(coord)

	var to_remove: Array = []
	for coord in chunks.keys():
		var dist = player_chunk.distance_to(coord)
		if dist > CULL_RADIUS_CHUNKS:
			to_remove.append(coord)

	for coord in to_remove:
		_cull_chunk(coord)

func _world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / CHUNK_SIZE), floor(world_pos.y / CHUNK_SIZE))

func _chunk_to_world_origin(chunk_coord: Vector2i) -> Vector2:
	return Vector2(chunk_coord.x * CHUNK_SIZE, chunk_coord.y * CHUNK_SIZE)

func _generate_chunk(chunk_coord: Vector2i) -> void:
	var origin = _chunk_to_world_origin(chunk_coord)
	var chunk_data = {"rocks": [], "clusters": []}

	for x in range(0, int(CHUNK_SIZE), int(CHUNK_CLUSTER_SAMPLE_GRID)):
		for y in range(0, int(CHUNK_SIZE), int(CHUNK_CLUSTER_SAMPLE_GRID)):
			var sample_pos = origin + Vector2(x + randf_range(-16, 16), y + randf_range(-16, 16))
			var noise_val = density_noise.get_noise_2d(sample_pos.x, sample_pos.y)
			var cluster_type := ""
			if noise_val > 0.65:
				cluster_type = "dense"
			elif noise_val > 0.35 and noise_val <= 0.65 and randf() < 0.35:
				cluster_type = "medium"
			if cluster_type != "" and can_place_cluster(sample_pos):
				var dict = {"pos": sample_pos, "type": cluster_type}
				cluster_centers_global.append(dict)
				chunk_data.clusters.append(dict)
				# Limit global cluster tracking to prevent memory bloat
				if cluster_centers_global.size() > 500:
					cluster_centers_global.remove_at(0)

	for cluster in chunk_data.clusters:
		var center = cluster.pos
		var cluster_type = cluster.type
		var base_count = ROCKS_PER_DENSE_CLUSTER if cluster_type == "dense" else ROCKS_PER_MEDIUM_CLUSTER
		var rock_count = int(float(base_count) * 0.5)
		for i in range(int(rock_count)):
			var angle = randf() * TAU
			var distance = abs(randfn(0.0, 0.5)) * CLUSTER_SPREAD
			var offset = Vector2(cos(angle), sin(angle)) * distance
			var pos = center + offset
			if pos.length() < PASSAGE_MIN_LENGTH and is_in_spawn_passage(pos):
				continue
			var rock_type = "large" if cluster_type == "dense" and randf() < 0.25 else choose_rock_type()
			var rock_radius = ROCK_SIZES[rock_type]
			if is_position_valid(pos, rock_radius):
				var rock = _instantiate_rock(rock_type, pos)
				chunk_data.rocks.append(rock)


	for i in range(CHUNK_SPARSE_ROCK_COUNT):
		var pos = origin + Vector2(randf_range(0, CHUNK_SIZE), randf_range(0, CHUNK_SIZE))
		if pos.length() < CLEAR_RADIUS:
			continue
		var too_close = false
		for cluster in chunk_data.clusters:
			if pos.distance_to(cluster.pos) < (CLUSTER_SPREAD + REQUIRED_PLAYER_CORRIDOR):
				too_close = true
				break
		if too_close:
			continue
		var rock_type = "small" if randf() < 0.85 else "medium"
		var rock_radius = ROCK_SIZES[rock_type]
		if is_position_valid(pos, rock_radius):
			var rock = _instantiate_rock(rock_type, pos)
			chunk_data.rocks.append(rock)

	chunks[chunk_coord] = chunk_data

func _instantiate_rock(rock_type: String, pos: Vector2) -> Node2D:
	var rock_scene
	match rock_type:
		"small": rock_scene = rock_small
		"medium": rock_scene = rock_medium
		"large": rock_scene = rock_large
	var rock = rock_scene.instantiate()
	rock.position = pos
	rock.rotation = randf() * TAU
	add_child(rock)
	add_to_spatial_grid(pos, ROCK_SIZES[rock_type])
	return rock

func _cull_chunk(coord: Vector2i) -> void:
	var chunk_data = chunks.get(coord, null)
	if not chunk_data:
		return
	
	# Clean up spatial grid entries for rocks in this chunk
	for rock in chunk_data.rocks:
		if is_instance_valid(rock):
			_remove_from_spatial_grid(rock.position)
			rock.queue_free()
	
	for cluster in chunk_data.clusters:
		for i in range(cluster_centers_global.size() - 1, -1, -1):
			if cluster_centers_global[i].pos == cluster.pos:
				cluster_centers_global.remove_at(i)
	chunks.erase(coord)

func _remove_from_spatial_grid(pos: Vector2) -> void:
	var grid_key = get_grid_key(pos)
	if spatial_grid.has(grid_key):
		for i in range(spatial_grid[grid_key].size() - 1, -1, -1):
			if spatial_grid[grid_key][i].position.distance_to(pos) < 1.0:
				spatial_grid[grid_key].remove_at(i)
				break
		if spatial_grid[grid_key].is_empty():
			spatial_grid.erase(grid_key)
