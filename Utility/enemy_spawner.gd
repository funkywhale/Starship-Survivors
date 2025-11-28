extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var difficulty_manager: Node = null
var cached_viewport_size: Vector2 = Vector2.ZERO
var cache_update_counter: int = 0

# Enemy count management
var active_enemy_count: int = 0
const MAX_ENEMIES: int = 200
const CLEANUP_CHECK_INTERVAL: int = 30
var cleanup_timer: int = 0


const TELEPORT_DISTANCE: float = 800.0
const REPOSITION_DISTANCE: float = 400.0
const MAX_REPOSITION_CANDIDATES: int = 40
var enemy_list: Array = []

@export var time: int = 0

signal changetime(time)

func _ready() -> void:
	connect("changetime", Callable(player, "change_time"))
	difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	if not difficulty_manager:
		difficulty_manager = preload("res://Utility/difficulty_manager.gd").new()
		difficulty_manager.name = "DifficultyManager"
		difficulty_manager.add_to_group("difficulty_manager")
		add_child(difficulty_manager)

func _on_timer_timeout() -> void:
	time += 1
	cleanup_timer += 1
	
	var cleanup_interval = CLEANUP_CHECK_INTERVAL
	if active_enemy_count > 150:
		cleanup_interval = 10
	
	if cleanup_timer >= cleanup_interval:
		cleanup_timer = 0
		_cleanup_dead_enemies()
	
	if time % 3 == 0:
		var far_behind = _count_far_behind_enemies()
		if far_behind >= 12:
			var subset = min(6, int(floor(far_behind / 2.0)))
			if subset > 0:
				_reposition_far_enemies(subset)

	var enemy_spawns = spawns
	var spawn_rate_mult = 1.0
	var enemy_count_mult = 1.0
	if difficulty_manager:
		spawn_rate_mult = difficulty_manager.get_spawn_rate_multiplier()
		enemy_count_mult = difficulty_manager.get_enemy_count_multiplier()

	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			var adjusted_spawn_delay = max(1, int(i.enemy_spawn_delay / spawn_rate_mult))

			if i.spawn_delay_counter < adjusted_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy

				var is_boss = false
				if new_enemy and new_enemy.resource_path.contains("enemy_boss"):
					is_boss = true
					var existing_bosses = get_tree().get_nodes_in_group("boss")
					if existing_bosses.size() > 0:
						continue

				var base_spawn_reduction = 0.85
				var adjusted_enemy_num = max(1, int(i.enemy_num * enemy_count_mult * base_spawn_reduction))
				
				if is_boss:
					adjusted_enemy_num = 1

				var counter = 0
				while counter < adjusted_enemy_num:
					if not is_boss and active_enemy_count >= MAX_ENEMIES:
						_reposition_far_enemies(adjusted_enemy_num - counter)
						break
					
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					
					if enemy_spawn.has_signal("remove_from_array"):
						enemy_spawn.remove_from_array.connect(_on_enemy_removed)
					
					add_child(enemy_spawn)
					enemy_list.append(enemy_spawn)
					active_enemy_count += 1
					counter += 1
	emit_signal("changetime", time)

func get_random_position() -> Vector2:
	cache_update_counter += 1
	if cache_update_counter > 60 or cached_viewport_size == Vector2.ZERO:
		cached_viewport_size = get_viewport_rect().size
		cache_update_counter = 0
	
	var vpr = cached_viewport_size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
	var top_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
	var bottom_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
	var bottom_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)


	var max_attempts = 3
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO

	var p_dir = _get_player_direction()
	var prefer_side = "up"
	if p_dir.length() > 0.1:
		var angle = atan2(p_dir.y, p_dir.x)
		if abs(cos(angle)) > abs(sin(angle)):
			prefer_side = "right" if p_dir.x >= 0.0 else "left"
		else:
			prefer_side = "down" if p_dir.y >= 0.0 else "up"

	var side_weights: Array = []
	match prefer_side:
		"up":
			side_weights = ["up", "up", "up", "left", "right", "down"]
		"down":
			side_weights = ["down", "down", "down", "left", "right", "up"]
		"left":
			side_weights = ["left", "left", "left", "up", "down", "right"]
		"right":
			side_weights = ["right", "right", "right", "up", "down", "left"]

	for attempt in range(max_attempts):
		var pos_side = side_weights.pick_random()

		match pos_side:
			"up":
				spawn_pos1 = top_left
				spawn_pos2 = top_right
			"down":
				spawn_pos1 = bottom_left
				spawn_pos2 = bottom_right
			"right":
				spawn_pos1 = top_right
				spawn_pos2 = bottom_right
			"left":
				spawn_pos1 = top_left
				spawn_pos2 = bottom_left

		var x_spawn_attempt = randf_range(spawn_pos1.x, spawn_pos2.x)
		var y_spawn_attempt = randf_range(spawn_pos1.y, spawn_pos2.y)
		var spawn_position = Vector2(x_spawn_attempt, y_spawn_attempt)

		if not is_position_blocked_by_rock(spawn_position):
			return spawn_position


	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y, spawn_pos2.y)
	return Vector2(x_spawn, y_spawn)

func is_position_blocked_by_rock(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1
	var result = space_state.intersect_point(query, 1)

	return not result.is_empty()

func _on_enemy_removed(enemy) -> void:
	active_enemy_count = max(0, active_enemy_count - 1)
	if enemy_list.has(enemy):
		enemy_list.erase(enemy)

func _cleanup_dead_enemies() -> void:
	var actual_count = 0
	enemy_list.clear()
	
	for child in get_children():
		if child.is_in_group("enemy") or child.has_method("death"):
			if is_instance_valid(child):
				actual_count += 1
				enemy_list.append(child)
			else:
				child.queue_free()
	
	active_enemy_count = actual_count
	if active_enemy_count != actual_count:
		print("Enemy count corrected: ", active_enemy_count, " -> ", actual_count)

func _reposition_far_enemies(count_to_reposition: int) -> void:
	if not player or enemy_list.is_empty():
		return

	var player_direction = _get_player_direction()
	if player_direction == Vector2.ZERO:
		return

	player_direction = player_direction.normalized()

	var enemies_to_reposition: Array = []
	var behind_direction = - player_direction
	var teleport_distance_sq = TELEPORT_DISTANCE * TELEPORT_DISTANCE

	for enemy in enemy_list:
		if not is_instance_valid(enemy):
			continue
		var to_enemy = enemy.global_position - player.global_position
		var distance_sq = to_enemy.length_squared()
		if distance_sq > teleport_distance_sq:
			var dot = to_enemy.normalized().dot(behind_direction)
			if dot > 0.5:
				enemies_to_reposition.append(enemy)


	var num_to_reposition = int(enemies_to_reposition.size() * 0.8)
	if num_to_reposition < 1:
		num_to_reposition = enemies_to_reposition.size()
	if count_to_reposition > num_to_reposition:
		num_to_reposition = count_to_reposition

	if num_to_reposition > enemies_to_reposition.size():
		num_to_reposition = enemies_to_reposition.size()

	var repositioned = 0
	for i in range(num_to_reposition):
		if repositioned >= num_to_reposition:
			break
		var enemy = enemies_to_reposition[i]
		if not is_instance_valid(enemy):
			continue


		var vpr = cached_viewport_size * randf_range(1.1, 1.3)
		var base_pos = player.global_position + player_direction * REPOSITION_DISTANCE * randf_range(1.0, 1.3)
		var side_angle = randf_range(-0.7, 0.7)
		var spread_vec = player_direction.rotated(side_angle) * randf_range(100, vpr.x / 3)
		var new_position = base_pos + spread_vec

		if not is_position_blocked_by_rock(new_position):
			enemy.global_position = new_position
			repositioned += 1
		else:
			spread_vec = player_direction.rotated(-side_angle) * randf_range(100, vpr.x / 3)
			new_position = base_pos + spread_vec
			if not is_position_blocked_by_rock(new_position):
				enemy.global_position = new_position
				repositioned += 1

func _get_player_direction() -> Vector2:
	var player_velocity = Vector2.ZERO
	if player and player.has_method("get_velocity"):
		player_velocity = player.get_velocity()
	elif player and "velocity" in player:
		player_velocity = player.velocity

	if player_velocity.length() > 1.0:
		return player_velocity.normalized()
	elif player and "last_movement" in player and player.last_movement.length() > 0.1:
		return player.last_movement.normalized()
	elif player and "sprite" in player and player.sprite:
		return Vector2.UP.rotated(player.sprite.rotation)
	return Vector2.ZERO

func _count_far_behind_enemies() -> int:
	if enemy_list.is_empty() or not player:
		return 0
	var p_dir = _get_player_direction()
	if p_dir == Vector2.ZERO:
		return 0
	var behind_dir = - p_dir
	var teleport_distance_sq = TELEPORT_DISTANCE * TELEPORT_DISTANCE
	var count = 0
	for enemy in enemy_list:
		if not is_instance_valid(enemy):
			continue
		var to_enemy = enemy.global_position - player.global_position
		if to_enemy.length_squared() > teleport_distance_sq:
			var dot = to_enemy.normalized().dot(behind_dir)
			if dot > 0.5:
				count += 1
	return count
