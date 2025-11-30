extends BaseWeaponProjectile

var attack_speed: float = 3.0
var trail_damage: int = 3
var trail_size: float = 1.0
var play_sound: bool = true

var target: Vector2 = Vector2.ZERO
var angle: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite2D
@onready var particles: GPUParticles2D = $GPUParticles2D

var plasma_trail_scene: PackedScene = preload("res://Player/Attack/plasma_trail.tscn")

func _init():
	weapon_id = "plasma"

func _apply_critical_strike() -> void:
	damage *= 2
	trail_damage *= 2
	hp *= 2

func _load_additional_stats(stats: Dictionary) -> void:
	trail_damage = stats.get("trail_damage", 5)
	if player:
		trail_damage += player.damage_bonus

func _apply_weapon_specific_setup() -> void:
	if player:
		level = int(player.plasma_level)
		attack_speed = float(player.pulselaser_attackspeed) * 2.0
		trail_size = 1.0 * (1 + player.spell_size)
	
	if target == Vector2.ZERO and player:
		target = player.get_closest_target()
	angle = global_position.direction_to(target)
	rotation = angle.angle()

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if play_sound:
		$snd_play.play()

func _ready() -> void:
	if not _initialize_weapon():
		return
	_apply_weapon_specific_setup()


func _physics_process(delta: float) -> void:
	position += angle * speed * delta

func enemy_hit(charge: int = 1) -> void:
	hp -= charge
	if hp <= 0:
		cleanup_and_remove()

func _on_timer_timeout() -> void:
	cleanup_and_remove()

func cleanup_and_remove() -> void:
	if particles and is_instance_valid(particles):
		particles.emitting = false
		particles.one_shot = true

		var final_position = particles.global_position
		var world = get_tree().current_scene

		if particles.has_method("set"):
			particles.set("local_coords", false)

		if world:
			var prev_parent = particles.get_parent()
			if prev_parent and prev_parent != world:
				prev_parent.remove_child(particles)
			world.call_deferred("add_child", particles)
			particles.call_deferred("set", "global_position", final_position)
		else:
			var prev_parent = particles.get_parent()
			if prev_parent and prev_parent != get_tree().root:
				prev_parent.remove_child(particles)
			get_tree().root.call_deferred("add_child", particles)
			particles.call_deferred("set", "global_position", final_position)

		var cleanup_timer = Timer.new()
		cleanup_timer.wait_time = particles.lifetime + particles.preprocess
		cleanup_timer.one_shot = true
		cleanup_timer.timeout.connect(func():
			if is_instance_valid(particles):
				particles.queue_free()
			cleanup_timer.queue_free()
		)
		if world:
			world.call_deferred("add_child", cleanup_timer)
		else:
			get_tree().root.call_deferred("add_child", cleanup_timer)
		cleanup_timer.call_deferred("start")
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
		cleanup_and_remove()

func _on_trail_spawn_timer_timeout() -> void:
	if plasma_trail_scene:
		var trail = plasma_trail_scene.instantiate()
		trail.damage = trail_damage
		trail.knockback_amount = int(knockback_amount / 5.0)
		trail.scale = Vector2(trail_size, trail_size)
		

		trail.global_position = global_position
		

		var world = get_tree().current_scene
		if world:
			world.call_deferred("add_child", trail)
		else:
			get_tree().root.call_deferred("add_child", trail)
