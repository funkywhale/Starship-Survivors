extends Node2D

# Rock scene references
var rock_small = preload("res://Objects/rock_small.tscn")
var rock_medium = preload("res://Objects/rock_medium.tscn")
var rock_large = preload("res://Objects/rock_large.tscn")

# Generation parameters
const WORLD_SIZE = 2000.0  # Total area: 2000x2000 pixels
const CLEAR_RADIUS = 300.0  # Clear area around player spawn
const MIN_ROCK_DISTANCE = 4.0  # Minimum space between rocks

# Rock size parameters (radii from collision shapes)
const ROCK_SIZES = {
	"small": 6.0,
	"medium": 12.0,
	"large": 18.0
}

# Cluster-based terrain generation parameters (like Minecraft trees)
const NUM_DENSE_CLUSTERS = 25  # Number of dense asteroid clusters (reduced from 40)
const NUM_MEDIUM_CLUSTERS = 30  # Number of medium clusters
const ROCKS_PER_DENSE_CLUSTER = 200  # Rocks in each dense cluster (45% reduction)
const ROCKS_PER_MEDIUM_CLUSTER = 75  # Rocks in each medium cluster (45% reduction)
const SPARSE_ROCK_COUNT = 500  # Scattered rocks between clusters (45% reduction)
const CLUSTER_SPREAD = 85.0  # How spread out rocks are within a cluster (smaller area)

# Spawn passage parameters
const NUM_PASSAGES = 8  # Number of passages radiating from spawn
const PASSAGE_WIDTH = 100.0  # Width of each passage
const PASSAGE_MIN_LENGTH = 600.0  # How far passages extend from spawn

# Rock distribution weights (relative spawn chances)
const ROCK_WEIGHTS = {
	"small": 0.5,    # 50% small rocks
	"medium": 0.35,  # 35% medium rocks
	"large": 0.15    # 15% large rocks
}

# Spatial grid for efficient collision checking
var spatial_grid = {}
var grid_cell_size = 100.0

# Track generated rocks
var generated_rocks = []

# Noise generator for cluster placement (like Minecraft tree spawning)
var density_noise: FastNoiseLite

func _ready():
	# Initialize noise generators
	setup_noise_generators()
	# Generate rocks when added to scene
	generate_rocks()

func setup_noise_generators():
	# Get time-based seed for truly random terrains each run
	var seed_value = Time.get_ticks_msec()

	print("Rock Manager: Generating cluster-based terrain with seed: ", seed_value)

	# Noise for cluster placement (like Minecraft determines where trees spawn)
	density_noise = FastNoiseLite.new()
	density_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	density_noise.seed = seed_value
	density_noise.frequency = 0.005  # Organic cluster distribution
	density_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	density_noise.fractal_octaves = 3

func generate_rocks():
	# Clear any existing rocks
	clear_rocks()

	# Generate rocks using cluster-based approach (like Minecraft trees)
	generate_cluster_based_terrain()

	print("Rock Manager: Generated ", generated_rocks.size(), " rocks in cluster-based terrain")

func generate_cluster_based_terrain():
	# Generate clusters using noise (like Minecraft tree placement)
	var half_world = WORLD_SIZE / 2.0
	var cluster_centers = []

	# Find cluster positions using noise
	# Sample the world and place clusters where noise is high
	var sample_grid = 100.0  # Sample every 100 pixels
	for x in range(-int(half_world), int(half_world), int(sample_grid)):
		for y in range(-int(half_world), int(half_world), int(sample_grid)):
			var pos = Vector2(x, y)

			# Skip if too close to player spawn
			if pos.length() < CLEAR_RADIUS + 200:
				continue

			# Skip if in a spawn passage (guaranteed clear paths from spawn)
			if is_in_spawn_passage(pos):
				continue

			# Use noise to determine if a cluster should spawn here
			var noise_val = density_noise.get_noise_2d(pos.x, pos.y)

			# Dense clusters in high noise areas
			if noise_val > 0.5 and cluster_centers.size() < NUM_DENSE_CLUSTERS:
				cluster_centers.append({"pos": pos, "type": "dense"})
			# Medium clusters in medium noise areas
			elif noise_val > 0.0 and noise_val <= 0.5 and randf() < 0.3:
				cluster_centers.append({"pos": pos, "type": "medium"})

	# Generate rocks within each cluster
	for cluster in cluster_centers:
		var center = cluster.pos
		var cluster_type = cluster.type
		var rock_count = ROCKS_PER_DENSE_CLUSTER if cluster_type == "dense" else ROCKS_PER_MEDIUM_CLUSTER

		# Scatter rocks around cluster center
		for i in range(rock_count):
			# Use gaussian-like distribution (more rocks near center)
			var angle = randf() * TAU
			var distance = abs(randfn(0.0, 0.5)) * CLUSTER_SPREAD
			var offset = Vector2(cos(angle), sin(angle)) * distance
			var pos = center + offset

			# Skip if in a spawn passage
			if is_in_spawn_passage(pos):
				continue

			# Choose rock type based on cluster type
			var rock_type = "large" if cluster_type == "dense" and randf() < 0.3 else choose_rock_type()
			var rock_radius = ROCK_SIZES[rock_type]

			# Check if position is valid
			if is_position_valid(pos, rock_radius):
				spawn_rock(rock_type, pos)
				add_to_spatial_grid(pos, rock_radius)

	# Add sparse scattered rocks in open areas
	for i in range(SPARSE_ROCK_COUNT):
		var pos = Vector2(
			randf_range(-half_world, half_world),
			randf_range(-half_world, half_world)
		)

		# Skip if too close to player spawn
		if pos.length() < CLEAR_RADIUS:
			continue

		# Skip if in a spawn passage
		if is_in_spawn_passage(pos):
			continue

		# Only place if far from any cluster center (true sparse areas)
		var too_close = false
		for cluster in cluster_centers:
			if pos.distance_to(cluster.pos) < CLUSTER_SPREAD * 1.5:
				too_close = true
				break

		if too_close:
			continue

		# Mostly small rocks in sparse areas
		var rock_type = "small" if randf() < 0.8 else "medium"
		var rock_radius = ROCK_SIZES[rock_type]

		if is_position_valid(pos, rock_radius):
			spawn_rock(rock_type, pos)
			add_to_spatial_grid(pos, rock_radius)


func is_in_spawn_passage(pos: Vector2) -> bool:
	# Check if position is in one of the radial passages from spawn
	# These passages guarantee navigation routes from spawn to outer areas

	# Distance from spawn
	var distance = pos.length()

	# Only create passages beyond the clear radius
	if distance < CLEAR_RADIUS or distance > PASSAGE_MIN_LENGTH:
		return false

	# Calculate angle from spawn to this position
	var angle_to_pos = atan2(pos.y, pos.x)
	if angle_to_pos < 0:
		angle_to_pos += TAU

	# Check each radial passage
	for i in range(NUM_PASSAGES):
		var passage_angle = (TAU / NUM_PASSAGES) * i
		var angle_diff = abs(angle_to_pos - passage_angle)

		# Handle wrap-around (e.g., 359 degrees vs 1 degree should be close)
		if angle_diff > PI:
			angle_diff = TAU - angle_diff

		# Convert angle difference to perpendicular distance from passage centerline
		var perpendicular_distance = distance * sin(angle_diff)

		# Check if within passage width
		if perpendicular_distance < PASSAGE_WIDTH / 2.0:
			return true

	return false

func choose_rock_type() -> String:
	var rand_value = randf()

	if rand_value < ROCK_WEIGHTS.small:
		return "small"
	elif rand_value < ROCK_WEIGHTS.small + ROCK_WEIGHTS.medium:
		return "medium"
	else:
		return "large"

func spawn_rock(rock_type: String, pos: Vector2):
	var rock_scene

	match rock_type:
		"small":
			rock_scene = rock_small
		"medium":
			rock_scene = rock_medium
		"large":
			rock_scene = rock_large

	var rock = rock_scene.instantiate()
	rock.position = pos
	# Randomize rotation for visual variety
	rock.rotation = randf() * TAU  # TAU = 2*PI (full rotation)
	add_child(rock)
	generated_rocks.append(rock)

func is_position_valid(pos: Vector2, radius: float) -> bool:
	# Check nearby grid cells for overlapping rocks
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

	# Check the cell and surrounding 8 cells
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
	# Remove all generated rocks
	for rock in generated_rocks:
		if is_instance_valid(rock):
			rock.queue_free()

	generated_rocks.clear()
	spatial_grid.clear()

func regenerate_rocks():
	# Called when player dies to create new layout
	# Reinitialize noise with new seed for different terrain
	setup_noise_generators()
	generate_rocks()
