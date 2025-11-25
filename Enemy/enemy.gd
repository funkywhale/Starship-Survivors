extends CharacterBody2D


@export var movement_speed: float = 20.0
@export var hp: int = 10
@export var knockback_recovery: float = 3.5
@export var experience: int = 1
@export var enemy_damage: int = 1
var knockback: Vector2 = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var loot_base = get_tree().get_first_node_in_group("loot")
@onready var sprite = $Sprite2D
@onready var anim = get_node_or_null("AnimationPlayer")
@onready var snd_hit = $snd_hit
@onready var player_collision_area = $PlayerCollisionArea

var difficulty_manager: Node = null
var base_movement_speed: float = 0.0
var current_speed_multiplier: float = 1.0
var has_collided_with_player: bool = false

# Obstacle avoidance
var obstacle_raycast: RayCast2D
var obstacle_check_distance: float = 90.0
var side_check_offset: float = 24.0
var side_check_fraction: float = 0.7

var death_anim: PackedScene = preload("res://Enemy/explosion.tscn")
var exp_gem: PackedScene = preload("res://Objects/experience_orb.tscn")

signal remove_from_array(object)


func _ready():
	# Add to enemy group for tracking
	add_to_group("enemy")
	
	var total_frames = 1
	if sprite and sprite.has_method("get_hframes"):
		total_frames = max(1, sprite.hframes * sprite.vframes)

	if anim and anim.has_animation("walk") and total_frames > 1:
		anim.play("walk")
	else:
		_set_sprite_frame_safe(0)

	# Connect to difficulty manager and store base speed
	difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	base_movement_speed = movement_speed
	
	# Connect player collision signal
	if player_collision_area:
		player_collision_area.body_entered.connect(_on_player_collision)

	# Allow non-boss enemies to collide with rocks while letting the boss ignore them
	var boss_unit := is_in_group("boss")
	set_collision_mask_value(2, not boss_unit)
	set_collision_layer_value(2, not boss_unit)
	
	# Setup obstacle detection raycast
	obstacle_raycast = RayCast2D.new()
	add_child(obstacle_raycast)
	obstacle_raycast.enabled = true
	obstacle_raycast.collision_mask = 2 # Layer 2 = rocks
	obstacle_raycast.hit_from_inside = false

func _on_player_collision(body: Node2D) -> void:
	# Simple collision detection - if enemy touches player, explode and damage them
	if body.is_in_group("player") and not has_collided_with_player:
		has_collided_with_player = true
		
		# Damage the player directly
		if body.has_method("take_enemy_damage"):
			body.take_enemy_damage(enemy_damage)
		
		# Enemy explodes immediately
		death()

func _set_sprite_frame_safe(frame_index: int) -> void:
	if not sprite:
		return
	var h = 1
	var v = 1
	if sprite.has_method("get_hframes"):
		h = max(1, sprite.hframes)
	if sprite.has_method("get_vframes"):
		v = max(1, sprite.vframes)
	var total = max(1, h * v)
	var safe = clamp(frame_index, 0, total - 1)
	if "frame" in sprite:
		sprite.frame = safe
	elif sprite.has_method("set_frame"):
		sprite.set_frame(safe)

func _physics_process(_delta: float) -> void:
	# Skip processing if already dead
	if not sprite or not sprite.visible or has_collided_with_player:
		return

	knockback = knockback.move_toward(Vector2.ZERO, knockback_recovery)

	# Apply difficulty speed multiplier (cached in _ready)
	if difficulty_manager:
		var difficulty = difficulty_manager.get_difficulty_level()
		# Direct proportional scaling - no hard limits
		# At 1.0 difficulty = 1.0x speed (normal)
		# At 0.5 difficulty = 0.5x speed (half speed)
		# At 2.0 difficulty = 2.0x speed (double speed)
		# Can scale infinitely based on difficulty
		current_speed_multiplier = difficulty
		movement_speed = base_movement_speed * current_speed_multiplier

	var direction = global_position.direction_to(player.global_position)

	# Steering to avoid rocks while still colliding with them
	if obstacle_raycast and Engine.get_frames_drawn() % 2 == 0:
		obstacle_raycast.global_position = global_position
		obstacle_raycast.target_position = direction * obstacle_check_distance
		obstacle_raycast.force_raycast_update()

		if obstacle_raycast.is_colliding():
			var collision_normal = obstacle_raycast.get_collision_normal()
			var right = Vector2(-direction.y, direction.x)
			var left = - right
			var side_offset = side_check_offset
			var check_dist = obstacle_check_distance * side_check_fraction
			var right_pos = global_position + right * side_offset
			var left_pos = global_position + left * side_offset
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsRayQueryParameters2D.create(
				right_pos,
				right_pos + direction * check_dist,
				2
			)
			var hit_right = space_state.intersect_ray(query)
			query.from = left_pos
			query.to = left_pos + direction * check_dist
			var hit_left = space_state.intersect_ray(query)
			var steer_dir := Vector2.ZERO
			if hit_right and not hit_left:
				steer_dir = left
			elif hit_left and not hit_right:
				steer_dir = right
			else:
				steer_dir = direction.slide(collision_normal).normalized()
			direction = (direction * 0.4 + steer_dir * 0.6).normalized()
	
	velocity = direction * movement_speed
	velocity += knockback

	move_and_slide()

	# Only update sprite flip occasionally to reduce overhead
	if Engine.get_frames_drawn() % 5 == 0:
		if direction.x > 0.1:
			sprite.flip_h = true
		elif direction.x < -0.1:
			sprite.flip_h = false

func death() -> void:
	emit_signal("remove_from_array", self)

	# Track kill for difficulty adjustment
	if difficulty_manager:
		difficulty_manager.record_kill()

	var enemy_death = death_anim.instantiate()
	enemy_death.scale = sprite.scale
	enemy_death.global_position = global_position
	get_parent().call_deferred("add_child", enemy_death)
	var new_gem = exp_gem.instantiate()
	new_gem.global_position = global_position
	new_gem.experience = experience
	loot_base.call_deferred("add_child", new_gem)
	queue_free()


func _on_hurt_box_hurt(damage, angle, knockback_amount):
	# Handles damage from player weapons (not player collision)
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
