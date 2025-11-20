extends Area2D

var level: int = 1
var hp: int = 3
var speed: float = 140.0
var damage: int = 10
var knockback_amount: int = 100
var attack_size: float = 1.0
var attack_speed: float = 3.0

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D

signal remove_from_array(object)

func _ready() -> void:
	if player:
		update_plasma()
	if target == Vector2.ZERO and player:
		target = player.get_closest_target()
	angle = global_position.direction_to(target)
	rotation = angle.angle()

	# Connect to body_entered to detect rock collisions
	body_entered.connect(_on_body_entered)
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(1, 1) * attack_size, 0.15).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	t.play()

func update_plasma() -> void:
	if player:
		level = int(player.plasma_level)
	else:
		level = int(level)

	var base_hp = 3
	var base_damage = 10
	var base_speed = 140.0

	match level:
		1:
			hp = base_hp
			damage = base_damage + (player.damage_bonus if player else 0)
			speed = base_speed
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			hp = base_hp + 1
			damage = base_damage + 2 + (player.damage_bonus if player else 0)
			speed = base_speed + 10.0
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			hp = base_hp + 2
			damage = base_damage + 4 + (player.damage_bonus if player else 0)
			speed = base_speed + 20.0
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			hp = base_hp + 3
			damage = base_damage + 6 + (player.damage_bonus if player else 0)
			speed = base_speed + 30.0
			attack_size = 1.0 * (1 + player.spell_size)

	if player:
		attack_speed = float(player.pulselaser_attackspeed) * 2.0
	scale = Vector2.ONE * attack_size

func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		queue_free()

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Destroy projectile when it hits a rock (StaticBody2D on layer 1)
	if body is StaticBody2D:
		emit_signal("remove_from_array", self)
		queue_free()
