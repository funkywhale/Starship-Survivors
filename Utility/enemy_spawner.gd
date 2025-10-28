extends Node2D


@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")
var difficulty_manager: Node = null

@export var time = 0

signal changetime(time)

func _ready():
	connect("changetime",Callable(player,"change_time"))
	# Find or create difficulty manager
	difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	if not difficulty_manager:
		difficulty_manager = preload("res://Utility/difficulty_manager.gd").new()
		difficulty_manager.name = "DifficultyManager"
		difficulty_manager.add_to_group("difficulty_manager")
		add_child(difficulty_manager)

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns

	# Get difficulty multipliers
	var spawn_rate_mult = 1.0
	var enemy_count_mult = 1.0
	if difficulty_manager:
		spawn_rate_mult = difficulty_manager.get_spawn_rate_multiplier()
		enemy_count_mult = difficulty_manager.get_enemy_count_multiplier()

	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			# Apply difficulty to spawn delay (higher difficulty = faster spawns)
			var adjusted_spawn_delay = max(1, int(i.enemy_spawn_delay / spawn_rate_mult))

			if i.spawn_delay_counter < adjusted_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy

				# Apply difficulty to enemy count (higher difficulty = more enemies)
				# Base spawn reduction: 0.85x the normal amount for better balance
				var base_spawn_reduction = 0.85
				var adjusted_enemy_num = max(1, int(i.enemy_num * enemy_count_mult * base_spawn_reduction))

				var counter = 0
				while  counter < adjusted_enemy_num:
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1
	emit_signal("changetime",time)

func get_random_position():
	var vpr = get_viewport_rect().size * randf_range(1.1,1.4)
	var top_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y - vpr.y/2)
	var top_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y - vpr.y/2)
	var bottom_left = Vector2(player.global_position.x - vpr.x/2, player.global_position.y + vpr.y/2)
	var bottom_right = Vector2(player.global_position.x + vpr.x/2, player.global_position.y + vpr.y/2)
	var pos_side = ["up","down","right","left"].pick_random()
	var spawn_pos1 = Vector2.ZERO
	var spawn_pos2 = Vector2.ZERO
	
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
	
	var x_spawn = randf_range(spawn_pos1.x, spawn_pos2.x)
	var y_spawn = randf_range(spawn_pos1.y,spawn_pos2.y)
	return Vector2(x_spawn,y_spawn)
