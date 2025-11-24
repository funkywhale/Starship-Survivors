extends Area2D

var level: int = 1
var hp: int = 9999
var speed: float = 100.0
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var last_movement: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO
var angle_less: Vector2 = Vector2.ZERO
var angle_more: Vector2 = Vector2.ZERO
var exploded: bool = false

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")
@onready var ExplosionScene = preload("res://Player/Attack/explosion_area.tscn")

func _has_prop(obj, prop_name: String) -> bool:
	for p in obj.get_property_list():
		if p.get("name", "") == prop_name:
			return true
	return false

func _ready():
	match level:
		1:
			hp = 1
			speed = 100.0
			damage = 10 + (player.damage_bonus if player else 0)
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			speed = 100.0
			damage = 10 + (player.damage_bonus if player else 0)
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 1
			speed = 100.0
			damage = 10 + (player.damage_bonus if player else 0)
			knockback_amount = 100
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 1
			speed = 100.0
			damage = 10 + (player.damage_bonus if player else 0)
			knockback_amount = 125
			attack_size = 1.0 * (1 + player.spell_size)

			
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	var lm = last_movement
	if lm.length() < 0.01:
		lm = Vector2.UP
	else:
		lm = lm.normalized()


	var spread_min = randf_range(0.15, 0.35)
	var spread_max = randf_range(0.7, 1.2)

	var dir_less = lm.rotated(-spread_min)
	var dir_more = lm.rotated(spread_min)


	var dir_less_wide = lm.rotated(-spread_max)
	var dir_more_wide = lm.rotated(spread_max)

	move_to_less = global_position + dir_less * 500
	move_to_more = global_position + dir_more * 500


	if randi_range(0, 1) == 0:
		move_to_less = global_position + dir_less_wide * 500
	if randi_range(0, 1) == 0:
		move_to_more = global_position + dir_more_wide * 500

	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	# Apply rocket size immediately
	var final_scale = Vector2(1, 1) * attack_size
	scale = final_scale
	
	# Animate speed increase
	var final_speed = speed
	speed = speed / 5.0
	var speed_tween = create_tween()
	speed_tween.tween_property(self, "speed", final_speed, 6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	speed_tween.play()
	
	var tween = create_tween()
	var set_angle = randi_range(0, 1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
	else:
		angle = angle_more
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
		tween.tween_property(self, "angle", angle_less, 2)
		tween.tween_property(self, "angle", angle_more, 2)
	tween.play()

	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	if angle != Vector2.ZERO:
		rotation = angle.angle() + PI / 2
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		_spawn_explosion()

func _on_timer_timeout() -> void:
	_cleanup()

func _cleanup() -> void:
	# Kill any running tweens to prevent memory leaks
	var tween_node = get_node_or_null("Tween")
	if tween_node and tween_node is Tween:
		tween_node.kill()
	emit_signal("remove_from_array", self)
	queue_free()

func _spawn_explosion() -> void:
	if exploded:
		return
	exploded = true
	var explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	if _has_prop(explosion, "damage"):
		explosion.damage = damage
	else:
		explosion.set("damage", damage)
	if _has_prop(explosion, "knockback_amount"):
		explosion.knockback_amount = knockback_amount
	else:
		explosion.set("knockback_amount", knockback_amount)
	if _has_prop(explosion, "radius"):
		explosion.radius = 48.0 * attack_size
	else:
		explosion.set("radius", 48.0 * attack_size)
	if _has_prop(explosion, "angle"):
		explosion.angle = angle
	else:
		explosion.set("angle", angle)
	var root = get_tree().get_current_scene()
	if root:
		root.call_deferred("add_child", explosion)
	else:
		get_parent().call_deferred("add_child", explosion)
	_cleanup()

func _on_body_entered(body: Node2D) -> void:
	# Explode when hitting a rock (CharacterBody2D with rock.gd script)
	if body.get_script() and body.get_script().resource_path.ends_with("rock.gd"):
		_spawn_explosion()

func _on_area_entered(_area: Area2D) -> void:
	# This might be used for other interactions in the future
	pass
