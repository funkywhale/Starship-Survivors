extends Area2D
class_name BaseWeaponProjectile

var weapon_id: String = ""
var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: int = 10
var knockback_amount: int = 50
var attack_size: float = 1.0
var is_critical: bool = false

# Lifetime-based cleanup to avoid projectile accumulation
var lifetime: float = 10.0
var _age: float = 0.0

@export var screen_cleanup_margin: float = 4096.0

@onready var player = get_tree().get_first_node_in_group("player")

signal remove_from_array(object)

@export var ignore_screen_exit: bool = true

func _ready() -> void:
	set_process(true)
	if not ignore_screen_exit:
		var vn = VisibleOnScreenNotifier2D.new()
		vn.name = "VisibilityNotifier"
		vn.margin = screen_cleanup_margin
		if not vn.is_connected("screen_exited", Callable(self, "_on_screen_exited")):
			vn.connect("screen_exited", Callable(self, "_on_screen_exited"))
		add_child(vn)
	else:
		print("BaseWeaponProjectile: ignoring screen-exit cleanup for", self)

func _process(delta: float) -> void:
	_age += delta
	if lifetime > 0.0 and _age >= lifetime:
		_standard_cleanup()

func _on_screen_exited() -> void:
	var cam = null
	if get_viewport() and get_viewport().has_method("get_camera_2d"):
		cam = get_viewport().get_camera_2d()
	print("[Projectile] screen_exited ->", self, "pos=", global_position, "age=", _age, "lifetime=", lifetime, "parent=", get_parent(), "camera=", cam)
	if ignore_screen_exit:
		return
	_standard_cleanup()

func _get_applied_modifiers() -> Dictionary:
	return {
		"damage_bonus": true,
		"spell_size": true,
		"projectile_speed": true,
		"knockback": true,
	}

func _apply_critical_strike() -> void:
	damage *= 2

func _load_additional_stats(_stats: Dictionary) -> void:
	pass

func _apply_weapon_specific_setup() -> void:
	pass

func _initialize_weapon() -> bool:
	if player and player.has_method("roll_critical"):
		is_critical = player.roll_critical()
	
	if weapon_id.is_empty():
		push_error("BaseWeaponProjectile: weapon_id not set in child class")
		return false
	var stats = WeaponRegistry.get_weapon_stats(weapon_id, level)
	if stats.is_empty():
		push_error("%s: Failed to get stats for level %d" % [weapon_id, level])
		return false
	hp = stats.get("hp", 1)
	speed = stats.get("speed", 100.0)
	damage = stats.get("damage", 10)
	knockback_amount = stats.get("knockback", 50)
	attack_size = stats.get("size", 1.0)
	
	_load_additional_stats(stats)
	if player:
		var modifiers = _get_applied_modifiers()
		
		if modifiers.get("damage_bonus", true):
			damage += player.damage_bonus
		
		if modifiers.get("spell_size", true):
			attack_size *= (1.0 + player.spell_size)
		
		if modifiers.get("projectile_speed", true):
			speed *= (1.0 + player.projectile_speed_multiplier)
		
		if modifiers.get("knockback", true):
			knockback_amount = int(knockback_amount * (1.0 + player.knockback_multiplier))
		
		if is_critical:
			_apply_critical_strike()
	scale = Vector2.ONE * attack_size
	
	return true

func _standard_cleanup() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		_standard_cleanup()

func _on_body_entered(body: Node2D) -> void:
	var is_rock := false
	if body.get_script():
		var script_path = body.get_script().resource_path
		if script_path.ends_with("rock.gd"):
			is_rock = true
	if not is_rock and body.is_in_group("rock"):
		is_rock = true
	if is_rock:
		_standard_cleanup()
