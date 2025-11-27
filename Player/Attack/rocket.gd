extends BaseWeaponProjectile

var direction: Vector2 = Vector2.ZERO
var homing_delay: float = 1.0
var homing_time: float = 0.0
var homing_active: bool = false
var homing_turn_speed: float = 1.0
var homing_max_distance: float = 900.0
var homing_target: Node2D = null

# Lifetime
var max_lifetime: float = 4.5
var age: float = 0.0

var exploded: bool = false

@onready var ExplosionScene = preload("res://Player/Attack/explosion_area.tscn")

func _init():
	weapon_id = "rocket"

func _apply_critical_strike() -> void:
	damage *= 2

func _has_prop(obj, prop_name: String) -> bool:
	for p in obj.get_property_list():
		if p.get("name", "") == prop_name:
			return true
	return false

func _apply_weapon_specific_setup() -> void:
	hp = 1
	var forward := Vector2.UP
	if player and player.has_node("Sprite2D"):
		var spr: Node2D = player.get_node("Sprite2D")
		forward = Vector2.UP.rotated(spr.rotation)
	direction = forward.normalized()
	rotation = direction.angle() + PI / 2

	homing_time = 0.0
	homing_active = false
	homing_target = null

	if not is_connected("area_entered", Callable(self, "_on_area_entered")):
		connect("area_entered", Callable(self, "_on_area_entered"))
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _ready():
	if not _initialize_weapon():
		return
	_apply_weapon_specific_setup()

func _physics_process(delta: float) -> void:
	# Update timers
	age += delta
	if age >= max_lifetime and not exploded:
		_spawn_explosion()
		return

	homing_time += delta
	if not homing_active and homing_time >= homing_delay:
		homing_active = true
		_pick_homing_target()

	if homing_active:
		_update_homing(delta)

	if direction != Vector2.ZERO:
		rotation = direction.angle() + PI / 2
	position += direction * speed * delta

	# Auto-cleanup if far away from player (failsafe)
	if player and global_position.distance_to(player.global_position) > 3000.0:
		_cleanup()

func _pick_homing_target() -> void:
	# Choose a single target once when homing starts; no retargeting.
	var enemy_group := get_tree().get_nodes_in_group("enemy")
	var best_enemy: Node2D = null
	var best_dist: float = homing_max_distance
	for e in enemy_group:
		if not is_instance_valid(e):
			continue
		if not ("global_position" in e):
			continue
		var enemy_pos: Vector2 = e.global_position
		var to_enemy: Vector2 = enemy_pos - global_position
		var dist: float = to_enemy.length()
		if dist <= 0.01 or dist > homing_max_distance:
			continue
		# Prefer enemies generally in front of the rocket (narrow cone)
		var dir: Vector2 = to_enemy / dist
		var dot: float = dir.dot(direction)
		if dot < 0.7: # about 45 degrees cone
			continue
		if dist < best_dist:
			best_dist = dist
			best_enemy = e
	homing_target = best_enemy
	if homing_target == null:
		homing_active = false

func _update_homing(delta: float) -> void:
	if not homing_target or not is_instance_valid(homing_target):
		homing_active = false
		return
	var enemy_pos: Vector2 = homing_target.global_position
	var to_enemy: Vector2 = enemy_pos - global_position
	var dist: float = to_enemy.length()
	if dist <= 0.01:
		return
	var target_dir: Vector2 = to_enemy / dist
	# Smoothly rotate current direction toward target_dir (limited turn rate)
	var current_angle: float = direction.angle()
	var target_angle: float = target_dir.angle()
	var diff: float = wrapf(target_angle - current_angle, -PI, PI)
	var max_step: float = homing_turn_speed * delta
	var step: float = clamp(diff, -max_step, max_step)
	var new_angle_val: float = current_angle + step
	direction = Vector2.RIGHT.rotated(new_angle_val).normalized()

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		_spawn_explosion()

func _on_timer_timeout() -> void:
	_cleanup()

func _cleanup() -> void:
	_standard_cleanup()

func _spawn_explosion() -> void:
	if exploded:
		return
	exploded = true
	var explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	
	var stats = WeaponRegistry.get_weapon_stats("rocket", level)
	var explosion_dmg = stats.get("explosion_damage", damage)
	if player:
		explosion_dmg += player.damage_bonus
	
	if _has_prop(explosion, "damage"):
		explosion.damage = explosion_dmg
	else:
		explosion.set("damage", explosion_dmg)
	if _has_prop(explosion, "knockback_amount"):
		explosion.knockback_amount = knockback_amount
	else:
		explosion.set("knockback_amount", knockback_amount)
	
	var base_radius = stats.get("explosion_radius", 48.0)
	if _has_prop(explosion, "radius"):
		explosion.radius = base_radius * attack_size
	else:
		explosion.set("radius", base_radius * attack_size)
	if _has_prop(explosion, "angle"):
		explosion.angle = direction
	else:
		explosion.set("angle", direction)
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
