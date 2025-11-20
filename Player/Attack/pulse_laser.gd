extends Area2D

var level: int = 1
var hp: int = 1
var speed: float = 100.0
var damage: int = 5
var knockback_amount: int = 100
var attack_size: float = 1.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	angle = global_position.direction_to(target)
	rotation = angle.angle() + deg_to_rad(135)

	# Connect to body_entered to detect rock collisions
	body_entered.connect(_on_body_entered)
	match level:
		1:
			hp = 1
			speed = 100
			damage = 10 + (player.damage_bonus if player else 0)
			knockback_amount = 50
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = 1
			speed = 100
			damage = 10 + (player.damage_bonus if player else 0)
			knockback_amount = 50
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = 3
			speed = 100
			damage = 15 + (player.damage_bonus if player else 0)
			knockback_amount = 50
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = 4
			speed = 100
			damage = 15 + (player.damage_bonus if player else 0)
			knockback_amount = 50
			attack_size = 1.0 * (1 + player.spell_size)

	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * attack_size, 1).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()


func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Destroy projectile when it hits a rock (StaticBody2D on layer 1)
	if body is StaticBody2D:
		emit_signal("remove_from_array", self)
		queue_free()
