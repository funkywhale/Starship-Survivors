extends Area2D

var level: int = 1
var hp: int = 3
var speed: float = 140.0
var damage: int = 10
var knockback_amount: int = 100
var attack_size: float = 1.0
var attack_speed: float = 3.0
var trail_damage: int = 3
var trail_size: float = 1.0
var play_sound: bool = true

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D

var plasma_trail_scene: PackedScene = preload("res://Player/Attack/plasma_trail.tscn")

signal remove_from_array(object)

func _ready() -> void:
	if player:
		update_plasma()
	if target == Vector2.ZERO and player:
		target = player.get_closest_target()
	angle = global_position.direction_to(target)
	rotation = angle.angle()


	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if play_sound:
		$snd_play.play()

	scale = Vector2(1, 1) * attack_size

func update_plasma() -> void:
	if player:
		level = int(player.plasma_level)
	else:
		level = int(level)

	var base_hp = 3
	var base_damage = 15
	var base_speed = 140.0
	var base_trail_damage = 5

	match level:
		1:
			hp = base_hp
			damage = base_damage + (player.damage_bonus if player else 0)
			speed = base_speed
			attack_size = 1.0 * (1 + player.spell_size)
			trail_damage = base_trail_damage + (player.damage_bonus if player else 0)
		2:
			hp = base_hp + 1
			damage = base_damage + 10 + (player.damage_bonus if player else 0)
			speed = base_speed + 10.0
			attack_size = 1.0 * (1 + player.spell_size)
			trail_damage = base_trail_damage + 5 + (player.damage_bonus if player else 0)
		3:
			hp = base_hp + 2
			damage = base_damage + 20 + (player.damage_bonus if player else 0)
			speed = base_speed + 20.0
			attack_size = 1.0 * (1 + player.spell_size)
			trail_damage = base_trail_damage + 10 + (player.damage_bonus if player else 0)
		4:
			hp = base_hp + 3
			damage = base_damage + 30 + (player.damage_bonus if player else 0)
			speed = base_speed + 30.0
			attack_size = 1.0 * (1 + player.spell_size)
			trail_damage = base_trail_damage + 15 + (player.damage_bonus if player else 0)

	if player:
		attack_speed = float(player.pulselaser_attackspeed) * 2.0
		trail_size = 1.0 * (1 + player.spell_size)


func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		emit_signal("remove_from_array", self)
		cleanup_and_remove()

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array", self)
	cleanup_and_remove()

func cleanup_and_remove() -> void:
	if particles:
		particles.emitting = false
		particles.one_shot = true

		var final_position = particles.global_position
		particles.reparent(get_tree().root)
		particles.global_position = final_position

		var cleanup_timer = Timer.new()
		cleanup_timer.wait_time = particles.lifetime + particles.preprocess
		cleanup_timer.one_shot = true
		cleanup_timer.timeout.connect(func():
			if is_instance_valid(particles):
				particles.queue_free()
			cleanup_timer.queue_free()
		)
		get_tree().root.add_child(cleanup_timer)
		cleanup_timer.start()
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	var is_rock := false
	if body.get_script():
		var script_path = body.get_script().resource_path
		if script_path.ends_with("rock.gd"):
			is_rock = true
	if not is_rock and body.is_in_group("rock"):
		is_rock = true
	if is_rock:
		emit_signal("remove_from_array", self)
		cleanup_and_remove()

func _on_trail_spawn_timer_timeout() -> void:
	if plasma_trail_scene:
		var trail = plasma_trail_scene.instantiate()
		trail.global_position = global_position
		trail.damage = trail_damage
		trail.knockback_amount = int(knockback_amount / 5.0)
		trail.scale = Vector2(trail_size, trail_size)
		get_tree().root.call_deferred("add_child", trail)
