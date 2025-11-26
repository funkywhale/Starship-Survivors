extends CharacterBody2D


var hp: float = 80.0
var maxhp: float = 80.0
var last_movement: Vector2 = Vector2.UP
var time: int = 0

var max_speed: float = 40.0
var accel: float = 220.0
var decel: float = 320.0
var damping: float = 180.0
var rotation_speed_base: float = 3.2

var is_dashing: bool = false
var dash_boost: float = 140.0
var dash_duration: float = 1.2
var dash_cooldown: float = 6.0
var dash_time_left: float = 0.0
var dash_cooldown_left: float = 0.0
var post_dash_time: float = 0.0
var post_dash_duration: float = 0.5

var experience: int = 0
var experience_level: int = 1
var collected_experience: int = 0

var pulseLaser: PackedScene = preload("res://Player/Attack/pulse_laser.tscn")
var rocket: PackedScene = preload("res://Player/Attack/rocket.tscn")
var plasma: PackedScene = preload("res://Player/Attack/plasma.tscn")
var scatterShot: PackedScene = preload("res://Player/Attack/scatter_shot.tscn")
var ionLaser: PackedScene = preload("res://Player/Attack/ion_laser_beam.tscn")

@onready var pulseLaserTimer = get_node("%PulseLaserTimer")
@onready var pulseLaserAttackTimer = get_node("%PulseLaserAttackTimer")
@onready var rocketTimer = get_node("%RocketTimer")
@onready var rocketAttackTimer = get_node("%RocketAttackTimer")
@onready var plasmaBase = get_node("%PlasmaBase")
@onready var plasmaTimer = get_node("%PlasmaTimer")
@onready var plasmaAttackTimer = get_node("%PlasmaAttackTimer")
@onready var ionLaserTimer = get_node("%IonLaserTimer")
@onready var ionLaserAttackTimer = get_node("%IonLaserAttackTimer")

#UPGRADES
var collected_upgrades: Array = []
var upgrade_options: Array = []
var armor: int = 0
var spell_cooldown: float = 0.0
var spell_size: float = 0.0
var additional_attacks: int = 0
var damage_bonus: int = 0

#PulseLaser
var pulselaser_ammo: int = 0
var pulselaser_baseammo: int = 0
var pulselaser_attackspeed: float = 1.5
var pulselaser_level: int = 0

#Rocket
var rocket_ammo: int = 0
var rocket_baseammo: int = 0
var rocket_attackspeed: float = 3.0
var rocket_level: int = 0
var rocket_next_from_left: bool = false

# Plasma weapon state
var plasma_ammo: int = 0
var plasma_baseammo: int = 0
var plasma_level: int = 0
var plasma_attackspeed: float = 4.0

# Scatter Shot weapon state
var scattershot_level: int = 0
var scattershot_attackspeed: float = 2.0
var scattershot_damage: int = 5
var scattershot_penetration: int = 1

# Ion Laser weapon state
var ionlaser_level: int = 0
var ionlaser_attackspeed: float = 2.5
var ionlaser_ammo: int = 0
var ionlaser_baseammo: int = 0
var scattershot_pellets: int = 3
var scattershot_timer: float = 0.0

#Enemy Related
var enemy_close: Array = []
var targeted_enemies: Array = []

# Attack/Projectile tracking for cleanup
var active_projectile_count: int = 0
const MAX_PROJECTILES: int = 200

@onready var sprite = $Sprite2D
@onready var skin_manager = get_node("/root/SkinManager")
@onready var camera = $Camera2D

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var lblDifficulty = get_node_or_null("%lblDifficulty")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")


var difficulty_manager: Node = null
var intro_playing: bool = true
var move_anim_time: float = 0.0

signal playerdeath

func _ready() -> void:
	_apply_skin()
	var starting_weapon = skin_manager.get_starting_weapon()
	upgrade_character(starting_weapon)
	set_expbar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0.0, Vector2.ZERO, 0.0)
	difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	start_camera_intro()

func _apply_skin() -> void:
	if skin_manager == null:
		return

	var tex: Texture2D = skin_manager.get_equipped_texture()
	if tex:
		sprite.texture = tex
		sprite.hframes = 3
		sprite.vframes = 1
		sprite.scale = Vector2(0.5, 0.5)
	print("Player: applied skin = ", skin_manager.equipped)


func _physics_process(_delta: float) -> void:
	movement(_delta)
	
	var cleanup_frequency = 60
	if enemy_close.size() > 30 or active_projectile_count > 150:
		cleanup_frequency = 15
	
	if Engine.get_frames_drawn() % cleanup_frequency == 0:
		_cleanup_enemy_arrays()
		_cleanup_projectiles()
	
	if not intro_playing and scattershot_level > 0:
		scattershot_timer -= _delta
		if scattershot_timer <= 0:
			fire_scatter_shot()
			scattershot_timer = scattershot_attackspeed * (1 - spell_cooldown)

func movement(delta: float) -> void:
	if intro_playing:
		return

	if dash_cooldown_left > 0.0:
		dash_cooldown_left = max(dash_cooldown_left - delta, 0.0)
	if is_dashing:
		dash_time_left -= delta
		if dash_time_left <= 0.0:
			is_dashing = false
			post_dash_time = post_dash_duration
	
	if post_dash_time > 0.0:
		post_dash_time = max(post_dash_time - delta, 0.0)


	var turn = Input.get_action_strength("right") - Input.get_action_strength("left")
	var speed_ratio = 0.0
	if max_speed > 0:
		speed_ratio = clamp(velocity.length() / max_speed, 0.0, 1.0)
	var rotation_multiplier = 1.0 - (0.25 * speed_ratio)
	var effective_rotation_speed = rotation_speed_base * rotation_multiplier
	sprite.rotation += turn * effective_rotation_speed * delta
	var thrust = Input.get_action_strength("up") - Input.get_action_strength("down")
	var forward = Vector2.UP.rotated(sprite.rotation)
	if (Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("ui_select")) and dash_cooldown_left <= 0.0 and not is_dashing:
		is_dashing = true
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown
		velocity = forward * dash_boost

	if is_dashing or post_dash_time > 0.0:
		var boost_speed = 0.0
		
		if is_dashing:

			var dash_progress = 1.0 - (dash_time_left / dash_duration)
			var decay = exp(-dash_progress * 3.0)
			var falloff_factor = decay
			boost_speed = dash_boost * falloff_factor
		else:

			var transition_progress = 1.0 - (post_dash_time / post_dash_duration)

			var ease_out = pow(1.0 - transition_progress, 2.0)
			boost_speed = dash_boost * 0.15 * ease_out
		

		if thrust != 0:
			var accel_mult = 0.4 if is_dashing else 0.7
			velocity += forward * (accel * accel_mult) * thrust * delta
		

		var current_speed = velocity.length()
		var target_speed = max_speed + boost_speed
		var lerp_factor = 0.2 if is_dashing else 0.15
		var new_speed = lerp(current_speed, target_speed, lerp_factor)
		

		if velocity.length_squared() > 0.1:
			velocity = velocity.normalized() * new_speed
	else:
		if thrust != 0:
			velocity += forward * accel * thrust * delta

		var speed_len = velocity.length()
		var max_allowed_speed = max_speed
		if thrust < 0:
			max_allowed_speed = max_speed * 0.5
		if speed_len > max_allowed_speed:
			velocity = velocity.normalized() * max_allowed_speed

	move_and_slide()


	var is_thrusting = (Input.get_action_strength("up") - Input.get_action_strength("down")) != 0
	if is_thrusting or is_dashing:
		if velocity.length_squared() > 1.0:
			last_movement = velocity.normalized()
		move_anim_time += delta
		var anim_fps := 6.0
		var moving_frames := [1, 2]
		var idx := int(floor(move_anim_time * anim_fps)) % moving_frames.size()
		_set_player_frame(moving_frames[idx])
	else:
		move_anim_time = 0.0
		_set_player_frame(0)

func attack() -> void:
	if pulselaser_level > 0:
		pulseLaserTimer.wait_time = pulselaser_attackspeed * (1 - spell_cooldown)
		if pulseLaserTimer.is_stopped():
			pulseLaserTimer.start()
	if rocket_level > 0:
		rocketTimer.wait_time = rocket_attackspeed * (1 - spell_cooldown)
		if rocketTimer.is_stopped():
			rocketTimer.start()
	if plasma_level > 0:
		plasmaTimer.wait_time = float(plasma_attackspeed) * (1 - spell_cooldown)
		if plasmaTimer.is_stopped():
			plasmaTimer.start()
		if plasma_ammo > 0 and plasmaAttackTimer.is_stopped():
			plasmaAttackTimer.start()
	if ionlaser_level > 0:
		ionLaserTimer.wait_time = ionlaser_attackspeed * (1 - spell_cooldown)
		if ionLaserTimer.is_stopped():
			ionLaserTimer.start()
		if ionlaser_ammo > 0 and ionLaserAttackTimer.is_stopped():
			ionLaserAttackTimer.start()

func take_enemy_damage(damage: int) -> void:
	var actual_damage = max(damage - armor, 1)
	
	if not difficulty_manager:
		difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")
	
	if difficulty_manager:
		difficulty_manager.record_damage(actual_damage)
	
	var health_loss = actual_damage * 2.0
	hp -= health_loss
	healthBar.max_value = maxhp
	healthBar.value = hp
	
	if hp <= 0:
		death()

func _on_hurt_box_hurt(damage: float, _angle: Vector2, _knockback: float) -> void:
	var actual_damage = clamp(damage - armor, 1.0, 999.0)

	if not difficulty_manager:
		difficulty_manager = get_tree().get_first_node_in_group("difficulty_manager")

	if difficulty_manager and damage > 0:
		difficulty_manager.record_damage(actual_damage)

	var health_loss = actual_damage * 2.0
	hp -= health_loss
	healthBar.max_value = maxhp
	healthBar.value = hp

	if hp <= 0:
		death()

func _on_pulse_laser_timer_timeout():
	pulselaser_ammo += pulselaser_baseammo + additional_attacks
	if additional_attacks > 0:
		targeted_enemies.clear()
	pulseLaserAttackTimer.start()


func _on_pulse_laser_attack_timer_timeout():
	if pulselaser_ammo > 0 and active_projectile_count < MAX_PROJECTILES:
		var pulselaser_attack = pulseLaser.instantiate()
		var target_pos: Vector2
		if additional_attacks > 0:
			target_pos = get_different_target()
		else:
			target_pos = get_closest_target()
		pulselaser_attack.target = target_pos
		
		var laser_direction: float
		if target_pos != Vector2.UP:
			laser_direction = (target_pos - global_position).angle()
		else:
			laser_direction = sprite.rotation
		var offset = Vector2(12, 0).rotated(laser_direction)
		pulselaser_attack.position = position + offset
		
		pulselaser_attack.level = pulselaser_level
		pulselaser_attack.add_to_group("attack")
		add_child(pulselaser_attack)
		active_projectile_count += 1
		pulselaser_ammo -= 1
		if pulselaser_ammo > 0:
			pulseLaserAttackTimer.start()
		else:
			pulseLaserAttackTimer.stop()
			if additional_attacks > 0:
				targeted_enemies.clear()

func _on_rocket_timer_timeout():
	rocket_ammo += rocket_baseammo + additional_attacks
	rocketAttackTimer.start()

func _on_rocket_attack_timer_timeout():
	if rocket_ammo > 0 and active_projectile_count < MAX_PROJECTILES:
		var rocket_attack = rocket.instantiate()
		var rocket_direction: float = sprite.rotation
		var forward: Vector2 = Vector2.UP.rotated(rocket_direction)
		var right: Vector2 = Vector2.RIGHT.rotated(rocket_direction)
		var nose_offset: Vector2 = forward * 12.0
		var wing_offset_amount: float = 8.0
		var side_dir: Vector2 = - right if rocket_next_from_left else right
		var wing_offset: Vector2 = side_dir * wing_offset_amount
		rocket_next_from_left = not rocket_next_from_left
		var offset: Vector2 = nose_offset + wing_offset
		rocket_attack.position = position + offset
		rocket_attack.level = rocket_level
		rocket_attack.add_to_group("attack")
		add_child(rocket_attack)
		active_projectile_count += 1
		rocket_ammo -= 1
		if rocket_ammo > 0:
			rocketAttackTimer.start()
		else:
			rocketAttackTimer.stop()

func _on_plasma_timer_timeout():
	plasma_ammo += plasma_baseammo + additional_attacks
	if additional_attacks > 0:
		targeted_enemies.clear()
	plasmaAttackTimer.start()

func _on_plasma_attack_timer_timeout():
	if plasma_ammo > 0 and active_projectile_count < MAX_PROJECTILES:
		var plasma_attack = plasma.instantiate()
		var target_pos: Vector2 = Vector2.UP
		if additional_attacks > 0:
			target_pos = get_different_target()
			plasma_attack.target = target_pos
		
		var plasma_direction: float
		if target_pos != Vector2.UP:
			plasma_direction = (target_pos - global_position).angle()
		else:
			plasma_direction = sprite.rotation
		var offset = Vector2(12, 0).rotated(plasma_direction)
		plasma_attack.position = position + offset
		
		plasma_attack.level = plasma_level
		plasma_attack.add_to_group("attack")
		plasmaBase.add_child(plasma_attack)
		active_projectile_count += 1
		plasma_ammo -= 1
		if plasma_ammo > 0:
			plasmaAttackTimer.start()
		else:
			plasmaAttackTimer.stop()
			if additional_attacks > 0:
				targeted_enemies.clear()

func _on_ion_laser_timer_timeout():
	ionlaser_ammo += ionlaser_baseammo + additional_attacks
	if additional_attacks > 0:
		targeted_enemies.clear()
	ionLaserAttackTimer.start()

func _on_ion_laser_attack_timer_timeout():
	if ionlaser_ammo > 0 and active_projectile_count < MAX_PROJECTILES:
		var laser = ionLaser.instantiate()
		var target_pos: Vector2
		if additional_attacks > 0:
			target_pos = get_different_target()
		else:
			target_pos = get_closest_target()
		
		var laser_direction: float
		if target_pos != Vector2.UP:
			laser_direction = (target_pos - global_position).angle()
		else:
			laser_direction = sprite.rotation
		
		var offset = Vector2(12, 0).rotated(laser_direction)
		laser.global_position = global_position + offset
		laser.rotation = laser_direction
		laser.level = ionlaser_level
		laser.add_to_group("attack")
		get_parent().add_child(laser)
		active_projectile_count += 1
		ionlaser_ammo -= 1
		if ionlaser_ammo > 0:
			ionLaserAttackTimer.start()
		else:
			ionLaserAttackTimer.stop()
			if additional_attacks > 0:
				targeted_enemies.clear()

func get_different_target():
	for i in enemy_close.duplicate():
		if not is_instance_valid(i):
			enemy_close.erase(i)

	if enemy_close.size() == 0:
		return Vector2.UP

	var untargeted = []
	for e in enemy_close:
		if not is_instance_valid(e):
			continue
		if not targeted_enemies.has(e):
			var d = global_position.distance_to(e.global_position)
			untargeted.append({"enemy": e, "distance": d})

	if untargeted.size() == 0:
		targeted_enemies.clear()
		for e in enemy_close:
			if not is_instance_valid(e):
				continue
			var d = global_position.distance_to(e.global_position)
			untargeted.append({"enemy": e, "distance": d})

	if untargeted.size() == 0:
		return Vector2.UP

	untargeted.sort_custom(func(a, b): return a.distance < b.distance)
	var target = untargeted[0].enemy
	targeted_enemies.append(target)

	return target.global_position

func get_closest_target():
	for i in enemy_close.duplicate():
		if not is_instance_valid(i):
			enemy_close.erase(i)

	if enemy_close.size() == 0:
		return Vector2.UP

	var closest = null
	var closest_dist = INF
	for e in enemy_close:
		if not is_instance_valid(e):
			continue
		var d = global_position.distance_to(e.global_position)
		if d < closest_dist:
			closest_dist = d
			closest = e

	if closest:
		return closest.global_position
	else:
		return Vector2.UP

func fire_scatter_shot() -> void:
	var base_angle = sprite.rotation
	var cone_angle = deg_to_rad(30.0)
	var pellet_count = scattershot_pellets + additional_attacks
	var pellet_damage = scattershot_damage + damage_bonus
	var pellet_hp = scattershot_penetration
	var pellet_speed = 200.0
	var pellet_size = 1.0 * (1 + spell_size)
	

	var sound_player = get_node_or_null("ScatterShotAudio")
	if sound_player == null:
		sound_player = AudioStreamPlayer.new()
		sound_player.name = "ScatterShotAudio"
		sound_player.stream = preload("res://Audio/SoundEffect/scatter_shot.wav")
		sound_player.volume_db = -20.733
		sound_player.pitch_scale = 1.71
		add_child(sound_player)
	if not sound_player.playing:
		sound_player.play()
	
	for i in range(pellet_count):
		if active_projectile_count >= MAX_PROJECTILES:
			break
		
		var angle_offset = 0.0
		if pellet_count > 1:
			angle_offset = cone_angle * ((float(i) / float(pellet_count - 1)) - 0.5)
		
		var pellet = scatterShot.instantiate()
		var direction = Vector2.UP.rotated(base_angle + angle_offset)
		pellet.position = Vector2.UP.rotated(base_angle) * 8
		pellet.level = scattershot_level
		pellet.attack_size = pellet_size
		pellet.setup(direction, pellet_speed, pellet_damage, pellet_hp)
		add_child(pellet)
		active_projectile_count += 1


func _set_player_frame(frame_index: int) -> void:
	if not sprite:
		return
	var h = 1
	var v = 1
	if sprite.has_method("get_hframes"):
		h = sprite.get_hframes()
	else:
		if typeof(sprite.hframes) != TYPE_NIL:
			h = sprite.hframes
	if typeof(sprite.vframes) != TYPE_NIL:
		v = sprite.vframes

	var total = max(1, h * v)
	var idx = int(frame_index)
	if idx < 0:
		idx = 0
	elif idx >= total:
		idx = total - 1

	sprite.frame = idx


func _cleanup_enemy_arrays() -> void:
	enemy_close = enemy_close.filter(func(e): return is_instance_valid(e))
	targeted_enemies = targeted_enemies.filter(func(e): return is_instance_valid(e))
	

	if enemy_close.size() > 40:
		enemy_close.sort_custom(func(a, b):
			return global_position.distance_squared_to(a.global_position) < global_position.distance_squared_to(b.global_position)
		)
		enemy_close.resize(40)
	
	if targeted_enemies.size() > 15:
		targeted_enemies.clear()

func _cleanup_projectiles() -> void:
	var valid_count = 0
	var projectiles_to_remove = []
	

	for child in get_children():
		if child.is_in_group("attack"):
			if is_instance_valid(child):
				valid_count += 1
			else:
				projectiles_to_remove.append(child)
	
	if plasmaBase:
		for child in plasmaBase.get_children():
			if is_instance_valid(child):
				valid_count += 1
			else:
				projectiles_to_remove.append(child)
	

	for proj in projectiles_to_remove:
		if is_instance_valid(proj):
			proj.queue_free()
			valid_count -= 1
	
	active_projectile_count = max(0, valid_count)
	

	if active_projectile_count > MAX_PROJECTILES * 0.9:
		var to_remove = int((active_projectile_count - MAX_PROJECTILES * 0.8) * 1.5)
		var removed = 0
		for child in get_children():
			if child.is_in_group("attack") and removed < to_remove:
				child.queue_free()
				removed += 1
				active_projectile_count -= 1

func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp: int) -> void:
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required:
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

func calculate_experiencecap() -> int:
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
		
	return exp_cap
		
func set_expbar(set_value: int = 1, set_max_value: int = 100) -> void:
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup() -> void:
	sndLevelUp.play()
	lblLevel.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	for child in upgradeOptions.get_children():
		child.queue_free()
	upgrade_options.clear()
	var optionsmax = 3
	var available_options: Array = []
	while available_options.size() < optionsmax:
		var next_option: String = get_random_item()
		if next_option == "":
			break
		available_options.append(next_option)
	if available_options.is_empty():
		available_options.append("heal")
	for option_name in available_options:
		var option_choice = itemOptions.instantiate()
		option_choice.item = option_name
		upgradeOptions.add_child(option_choice)
	get_tree().paused = true

func upgrade_character(upgrade: String) -> void:
	match upgrade:
		"pulselaser1":
			pulselaser_level = 1
			pulselaser_baseammo += 1
		"pulselaser2":
			pulselaser_level = 2
			pulselaser_baseammo += 1
		"pulselaser3":
			pulselaser_level = 3
		"pulselaser4":
			pulselaser_level = 4
			pulselaser_baseammo += 2
		"rocket1":
			rocket_level = 1
			rocket_baseammo += 1
		"rocket2":
			rocket_level = 2
			rocket_baseammo += 1
		"rocket3":
			rocket_level = 3
			rocket_attackspeed -= 0.5
		"rocket4":
			rocket_level = 4
			rocket_baseammo += 1
		"plasma1":
			plasma_level = 1
			plasma_baseammo += 1
			plasma_ammo = plasma_baseammo
		"plasma2":
			plasma_level = 2
			plasma_baseammo += 1
		"plasma3":
			plasma_level = 3
			plasma_baseammo += 1
		"plasma4":
			plasma_level = 4
			plasma_baseammo += 1
		"scattershot1":
			scattershot_level = 1
			scattershot_pellets = 3
			scattershot_damage = 5
			scattershot_penetration = 1
			scattershot_attackspeed = 2.0
		"scattershot2":
			scattershot_level = 2
			scattershot_pellets = 5
			scattershot_damage = 7
			scattershot_penetration = 2
			scattershot_attackspeed = 1.8
		"scattershot3":
			scattershot_level = 3
			scattershot_pellets = 7
			scattershot_damage = 9
			scattershot_penetration = 3
			scattershot_attackspeed = 1.5
		"scattershot4":
			scattershot_level = 4
			scattershot_pellets = 9
			scattershot_damage = 12
			scattershot_penetration = 4
			scattershot_attackspeed = 1.2
		"ionlaser1":
			ionlaser_level = 1
			ionlaser_baseammo = 1
			ionlaser_attackspeed = 2.5
		"ionlaser2":
			ionlaser_level = 2
			ionlaser_attackspeed = 2.2
		"ionlaser3":
			ionlaser_level = 3
			ionlaser_attackspeed = 1.9
		"ionlaser4":
			ionlaser_level = 4
			ionlaser_attackspeed = 1.6
		"damage1":
			damage_bonus += 3
		"damage2":
			damage_bonus += 3
		"damage3":
			damage_bonus += 3
		"damage4":
			damage_bonus += 3
		"armor1", "armor2", "armor3", "armor4":
			armor += 1
		"speed1", "speed2", "speed3", "speed4":
			max_speed += 10.0
			accel += 1.0
			decel += 10.0
			damping += 10.0
		"thick1", "thick2", "thick3", "thick4":
			spell_size += 0.20
		"firerate1", "firerate2", "firerate3", "firerate4":
			spell_cooldown += 0.1
		"weapon1", "weapon2":
			additional_attacks += 1
		"heal":
			hp += 20
			hp = clamp(hp, 0, maxhp)
	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800, 50)
	get_tree().paused = false
	calculate_experience(0)
	
func get_random_item() -> String:
	var dblist: Array = []
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades:
			pass
		elif i in upgrade_options:
			pass
		elif UpgradeDb.UPGRADES[i]["type"] == "item":
			pass
		elif UpgradeDb.UPGRADES[i]["prerequisite"].size() > 0:
			var to_add = true
			for n in UpgradeDb.UPGRADES[i]["prerequisite"]:
				if not n in collected_upgrades:
					to_add = false
			if to_add:
				dblist.append(i)
		else:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return ""

func change_time(argtime: int = 0) -> void:
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lblTimer.text = str(get_m, ":", get_s)

	if lblDifficulty and difficulty_manager:
		var diff_text = difficulty_manager.get_difficulty_description()
		lblDifficulty.text = "Difficulty: " + diff_text

func adjust_gui_collection(upgrade: String) -> void:
	var get_upgraded_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var get_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if get_type != "item":
		var get_collected_displaynames = []
		for i in collected_upgrades:
			get_collected_displaynames.append(UpgradeDb.UPGRADES[i]["displayname"])
		if not get_upgraded_displayname in get_collected_displaynames:
			var new_item = itemContainer.instantiate()
			new_item.upgrade = upgrade
			match get_type:
				"weapon":
					collectedWeapons.add_child(new_item)
				"upgrade":
					collectedUpgrades.add_child(new_item)

func _submit_score_to_leaderboard() -> void:
	var profile_name = LocalProfile.get_current_profile()
	if profile_name.is_empty():
		print("No profile set, skipping leaderboard submission")
		return

	var score = time
	LocalProfile.submit_score(profile_name, score, experience_level)

func death() -> void:
	deathPanel.visible = true
	emit_signal("playerdeath")
	get_tree().paused = true
	var tween = deathPanel.create_tween()
	tween.tween_property(deathPanel, "position", Vector2(220, 50), 3.0).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.play()
	if time >= 300:
		lblResult.text = "You Win"
		sndVictory.play()
	else:
		lblResult.text = "You Lose"
		sndLose.play()

	_submit_score_to_leaderboard()


func _on_btn_leaderboard_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://Leaderboard/Leaderboard.tscn")

func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

func start_camera_intro():
	camera.zoom = Vector2(0.5, 0.5)
	get_tree().paused = true
	await get_tree().create_timer(1.0, true, false, true).timeout
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "zoom", Vector2(1.0, 1.0), 1.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	intro_playing = false
	get_tree().paused = false
	attack()
