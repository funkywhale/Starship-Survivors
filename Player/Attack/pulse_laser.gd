extends BaseWeaponProjectile

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

func _init():
	weapon_id = "pulselaser"

func _apply_critical_strike() -> void:
	damage *= 2
	hp *= 2

func _apply_weapon_specific_setup() -> void:
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _ready():
	if not _initialize_weapon():
		return
	_apply_weapon_specific_setup()

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func _on_timer_timeout():
	_standard_cleanup()
