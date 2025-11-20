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
@onready var hitBox = $HitBox

var difficulty_manager: Node = null
var base_movement_speed: float = 0.0
var current_speed_multiplier: float = 1.0

var death_anim: PackedScene = preload("res://Enemy/explosion.tscn")
var exp_gem: PackedScene = preload("res://Objects/experience_orb.tscn")

signal remove_from_array(object)


func _ready():
	var total_frames = 1
	if sprite and sprite.has_method("get_hframes"):
		total_frames = max(1, sprite.hframes * sprite.vframes)

	if anim and anim.has_animation("walk") and total_frames > 1:
		anim.play("walk")
	else:
		_set_sprite_frame_safe(0)
	hitBox.damage = enemy_damage

	# Connect to difficulty manager and store base speed
	difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	base_movement_speed = movement_speed

	# HitBox will deal damage through the hurt_box.gd system
	# Enemy will die after dealing damage through the HurtBoxType = 2 system

func on_damage_dealt():
	# Called when enemy HitBox deals damage to player
	# Make enemy disappear instantly
	if sprite:
		sprite.visible = false
	set_physics_process(false)
	call_deferred("death")

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
	if not sprite or not sprite.visible:
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
	velocity = direction * movement_speed
	velocity += knockback

	move_and_slide()

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
	hp -= damage
	knockback = angle * knockback_amount
	if hp <= 0:
		death()
	else:
		snd_hit.play()
