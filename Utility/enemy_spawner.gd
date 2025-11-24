extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var difficulty_manager: Node = null
var cached_viewport_size: Vector2 = Vector2.ZERO
var cache_update_counter: int = 0

# Enemy count management
var active_enemy_count: int = 0
const MAX_ENEMIES: int = 250 # Hard cap for web performance
const CLEANUP_CHECK_INTERVAL: int = 30 # Check every 30 seconds
var cleanup_timer: int = 0

# Enemy repositioning to prevent running away
const TELEPORT_DISTANCE: float = 800.0 # Distance behind player to check for far enemies
const REPOSITION_DISTANCE: float = 400.0 # Distance ahead of player to reposition
var enemy_list: Array = [] # Cache of all active enemies

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
	
	# More frequent cleanup when enemy count is high
	var cleanup_interval = CLEANUP_CHECK_INTERVAL
	if active_enemy_count > 150:
		cleanup_interval = 10 # Every 10 seconds when high load
	
	# Periodic cleanup of dead enemies
	if cleanup_timer >= cleanup_interval:
		cleanup_timer = 0
		_cleanup_dead_enemies()
	
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

				# Check if this is a boss enemy - bosses should only spawn once
				var is_boss = false
				if new_enemy and new_enemy.resource_path.contains("enemy_boss"):
					is_boss = true
					# Check if boss already exists in the scene
					var existing_bosses = get_tree().get_nodes_in_group("boss")
					if existing_bosses.size() > 0:
						continue # Skip spawning if boss already exists

				var base_spawn_reduction = 0.85
				var adjusted_enemy_num = max(1, int(i.enemy_num * enemy_count_mult * base_spawn_reduction))
				
				# Force boss to only spawn 1, regardless of difficulty multiplier
				if is_boss:
					adjusted_enemy_num = 1

				var counter = 0
				while counter < adjusted_enemy_num:
					# Bosses always spawn regardless of cap
					if not is_boss and active_enemy_count >= MAX_ENEMIES:
						_reposition_far_enemies(adjusted_enemy_num - counter)
						break
					
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					
					# Connect to enemy death signal to track count
					if enemy_spawn.has_signal("remove_from_array"):
						enemy_spawn.remove_from_array.connect(_on_enemy_removed)
					
					add_child(enemy_spawn)
					enemy_list.append(enemy_spawn)
					active_enemy_count += 1
					counter += 1
	emit_signal("changetime", time)

func get_random_position() -> Vector2:
	# Cache viewport size for performance (update every 60 spawns)
	cache_update_counter += 1
	if cache_update_counter > 60 or cached_viewport_size == Vector2.ZERO:
		cached_viewport_size = get_viewport_rect().size
		cache_update_counter = 0
	
	var vpr = cached_viewport_size * randf_range(1.1, 1.4)
	var top_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y - vpr.y / 2)
	var top_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y - vpr.y / 2)
	var bottom_left = Vector2(player.global_position.x - vpr.x / 2, player.global_position.y + vpr.y / 2)
	var bottom_right = Vector2(player.global_position.x + vpr.x / 2, player.global_position.y + vpr.y / 2)

	# Reduce rock check attempts for performance
	var max_attempts = 3 # Reduced from 10
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO

	for attempt in range(max_attempts):
		var pos_side = ["up", "down", "right", "left"].pick_random()

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
	# Track when enemies are removed
	active_enemy_count = max(0, active_enemy_count - 1)
	if enemy_list.has(enemy):
		enemy_list.erase(enemy)

func _cleanup_dead_enemies() -> void:
	# Recount actual enemies and rebuild list
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
	# Find enemies that are far behind the player and teleport them ahead
	if not player or enemy_list.is_empty():
		return
	
	# Get player's movement direction
	var player_velocity = Vector2.ZERO
	if player.has_method("get_velocity"):
		player_velocity = player.get_velocity()
	elif "velocity" in player:
		player_velocity = player.velocity
	
	# If player isn't moving, use last_movement or default to forward
	var player_direction = Vector2.ZERO
	if player_velocity.length() > 1.0:
		player_direction = player_velocity.normalized()
	elif "last_movement" in player and player.last_movement.length() > 0.1:
		player_direction = player.last_movement.normalized()
	else:
		# Default to sprite rotation if available
		if "sprite" in player and player.sprite:
			player_direction = Vector2.UP.rotated(player.sprite.rotation)
		else:
			player_direction = Vector2.UP
	
	# Find enemies behind the player
	var enemies_to_reposition = []
	var behind_direction = - player_direction
	
	for enemy in enemy_list:
		if not is_instance_valid(enemy):
			continue
		
		var to_enemy = enemy.global_position - player.global_position
		var distance = to_enemy.length()
		
		# Check if enemy is behind player and far away
		if distance > TELEPORT_DISTANCE:
			var dot = to_enemy.normalized().dot(behind_direction)
			if dot > 0.5: # Enemy is in the "behind" cone
				enemies_to_reposition.append({"enemy": enemy, "distance": distance})
	
	# Sort by distance (farthest first)
	enemies_to_reposition.sort_custom(func(a, b): return a.distance > b.distance)
	
	# Reposition the farthest enemies
	var repositioned = 0
	for enemy_data in enemies_to_reposition:
		if repositioned >= count_to_reposition:
			break
		
		var enemy = enemy_data.enemy
		if not is_instance_valid(enemy):
			continue
		
		# Teleport enemy ahead of player in their movement direction
		var forward_offset = player_direction * REPOSITION_DISTANCE
		var side_offset = Vector2(-player_direction.y, player_direction.x) * randf_range(-200, 200)
		var new_position = player.global_position + forward_offset + side_offset
		
		# Check if position is valid (not in rock)
		if not is_position_blocked_by_rock(new_position):
			enemy.global_position = new_position
			repositioned += 1
		else:
			# Try alternative position on opposite side
			side_offset = Vector2(player_direction.y, -player_direction.x) * randf_range(100, 300)
			new_position = player.global_position + forward_offset + side_offset
			if not is_position_blocked_by_rock(new_position):
				enemy.global_position = new_position
				repositioned += 1
