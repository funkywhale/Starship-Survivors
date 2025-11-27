extends BaseWeaponProjectile

var angle: Vector2 = Vector2.ZERO

func _init():
	weapon_id = "scattershot"

func _apply_critical_strike() -> void:
	damage *= 2
	hp *= 2

func _ready() -> void:
	add_to_group("attack")
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	scale = Vector2.ONE * attack_size

func setup(direction: Vector2, pellet_speed: float, pellet_damage: int, pellet_hp: int) -> void:
	angle = direction.normalized()
	speed = pellet_speed
	damage = pellet_damage
	hp = pellet_hp
	rotation = angle.angle() + deg_to_rad(90)

func _physics_process(delta: float) -> void:
	position += angle * speed * delta
