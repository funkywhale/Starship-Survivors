extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
var difficulty_manager: Node = null
var cached_viewport_size: Vector2 = Vector2.ZERO
var cache_update_counter: int = 0

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
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
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
