extends Area2D

var level: int = 1
var hp: int = 1
var speed: float = 200.0
var damage: int = 5
var knockback_amount: int = 50
var attack_size: float = 1.0

var angle: Vector2 = Vector2.ZERO

signal remove_from_array(object)

func _ready() -> void:
	# Add to attack group so hurt_box can detect it
	add_to_group("attack")

	# Connect to body_entered to detect rock collisions
	body_entered.connect(_on_body_entered)
	
	# Apply size scaling
	scale = Vector2.ONE * attack_size

func setup(direction: Vector2, pellet_speed: float, pellet_damage: int, pellet_hp: int) -> void:
	angle = direction.normalized()
	speed = pellet_speed
	damage = pellet_damage
	hp = pellet_hp
	# Sprite faces up (north), so add 90 degrees to point in movement direction
	rotation = angle.angle() + deg_to_rad(90)

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Destroy when hitting a rock. Rocks use `rock.gd` (CharacterBody2D), not StaticBody2D.
	var is_rock := false
	if body.get_script():
		var script_path = body.get_script().resource_path
		if script_path.ends_with("rock.gd"):
			is_rock = true
	# Optional group-based fallback if rocks are later grouped
	if not is_rock and body.is_in_group("rock"):
		is_rock = true
	if is_rock:
		emit_signal("remove_from_array", self)
		queue_free()
