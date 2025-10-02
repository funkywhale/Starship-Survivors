extends CharacterBody2D


var hp = 80
var maxhp = 80
var last_movement = Vector2.UP
var time = 0

var max_speed = 40.0
var accel = 220.0
var decel = 320.0
var damping = 180.0
var rotation_speed_base = 3.2

# Dash (forward boost) parameters
var is_dashing = false
var dash_boost = 140.0
var dash_duration = 0.30
var dash_cooldown = 3.0
var dash_time_left = 0.0
var dash_cooldown_left = 0.0

var experience = 0
var experience_level = 1
var collected_experience = 0

var pulseLaser = preload("res://Player/Attack/pulse_laser.tscn")
var rocket = preload("res://Player/Attack/rocket.tscn")
var plasma = preload("res://Player/Attack/plasma.tscn")

@onready var pulseLaserTimer = get_node("%PulseLaserTimer")
@onready var pulseLaserAttackTimer = get_node("%PulseLaserAttackTimer")
@onready var rocketTimer = get_node("%RocketTimer")
@onready var rocketAttackTimer = get_node("%RocketAttackTimer")
@onready var plasmaBase = get_node("%PlasmaBase")
@onready var plasmaTimer = get_node("%PlasmaTimer")
@onready var plasmaAttackTimer = get_node("%PlasmaAttackTimer")

#UPGRADES
var collected_upgrades = []
var upgrade_options = []
var armor = 0
var speed = 0
var spell_cooldown = 0
var spell_size = 0
var additional_attacks = 0
var damage_bonus = 0

#PulseLaser
var pulselaser_ammo = 0
var pulselaser_baseammo = 0
var pulselaser_attackspeed = 1.5
var pulselaser_level = 0

#Rocket
var rocket_ammo = 0
var rocket_baseammo = 0
var rocket_attackspeed = 3
var rocket_level = 0

# Plasma weapon state
var plasma_ammo = 0
var plasma_baseammo = 0
var plasma_level = 0
var plasma_attackspeed = 4.0


#Enemy Related
var enemy_close = []


@onready var sprite = $Sprite2D
@onready var walkTimer = get_node("%walkTimer")

#GUI
@onready var expBar = get_node("%ExperienceBar")
@onready var lblLevel = get_node("%lbl_level")
@onready var levelPanel = get_node("%LevelUp")
@onready var upgradeOptions = get_node("%UpgradeOptions")
@onready var itemOptions = preload("res://Utility/item_option.tscn")
@onready var sndLevelUp = get_node("%snd_levelup")
@onready var healthBar = get_node("%HealthBar")
@onready var lblTimer = get_node("%lblTimer")
@onready var collectedWeapons = get_node("%CollectedWeapons")
@onready var collectedUpgrades = get_node("%CollectedUpgrades")
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")

@onready var deathPanel = get_node("%DeathPanel")
@onready var lblResult = get_node("%lbl_Result")
@onready var sndVictory = get_node("%snd_victory")
@onready var sndLose = get_node("%snd_lose")

#Signal
signal playerdeath

func _ready():
	upgrade_character("pulselaser1")
	# upgrade_character("scattershot1")
	attack()
	set_expbar(experience, calculate_experiencecap())
	_on_hurt_box_hurt(0, 0, 0)

func _physics_process(_delta):
	movement(_delta)

func movement(delta: float):
	if dash_cooldown_left > 0.0:
		dash_cooldown_left = max(dash_cooldown_left - delta, 0.0)
	if is_dashing:
		dash_time_left -= delta
		if dash_time_left <= 0.0:
			is_dashing = false


	var turn = Input.get_action_strength("right") - Input.get_action_strength("left")
	var speed_ratio = 0.0
	if max_speed > 0:
		speed_ratio = clamp(velocity.length() / max_speed, 0.0, 1.0)
	var rotation_multiplier = 1.0 - (0.4 * speed_ratio)
	var effective_rotation_speed = rotation_speed_base * rotation_multiplier
	sprite.rotation += turn * effective_rotation_speed * delta
	var thrust = Input.get_action_strength("up") - Input.get_action_strength("down")
	var forward = Vector2.UP.rotated(sprite.rotation)
	if (Input.is_action_just_pressed("dash") or Input.is_action_just_pressed("ui_select")) and dash_cooldown_left <= 0.0 and not is_dashing:
		is_dashing = true
		dash_time_left = dash_duration
		dash_cooldown_left = dash_cooldown
		velocity = forward * dash_boost

	if not is_dashing:
		if thrust > 0:
			velocity += forward * accel * thrust * delta
		elif thrust < 0:
			velocity += forward * decel * thrust * delta
		else:
			velocity = velocity.move_toward(Vector2.ZERO, damping * delta)
		var speed_len = velocity.length()
		if speed_len > max_speed:
			velocity = velocity.normalized() * max_speed

	move_and_slide()

	if velocity.length_squared() > 1.0:
		last_movement = velocity.normalized()
		_set_player_frame(1)
	else:
		_set_player_frame(0)

func attack():
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

func _on_hurt_box_hurt(damage, _angle, _knockback):
	hp -= clamp(damage - armor, 1.0, 999.0)
	healthBar.max_value = maxhp
	healthBar.value = hp
	if hp <= 0:
		death()

func _on_pulse_laser_timer_timeout():
	pulselaser_ammo += pulselaser_baseammo + additional_attacks
	pulseLaserAttackTimer.start()


func _on_pulse_laser_attack_timer_timeout():
	if pulselaser_ammo > 0:
		var pulselaser_attack = pulseLaser.instantiate()
		pulselaser_attack.position = position
		pulselaser_attack.target = get_closest_target()
		pulselaser_attack.level = pulselaser_level
		add_child(pulselaser_attack)
		pulselaser_ammo -= 1
		if pulselaser_ammo > 0:
			pulseLaserAttackTimer.start()
		else:
			pulseLaserAttackTimer.stop()

func _on_rocket_timer_timeout():
	rocket_ammo += rocket_baseammo + additional_attacks
	rocketAttackTimer.start()

func _on_rocket_attack_timer_timeout():
	if rocket_ammo > 0:
		var rocket_attack = rocket.instantiate()
		rocket_attack.position = position
		rocket_attack.last_movement = last_movement
		rocket_attack.level = rocket_level
		add_child(rocket_attack)
		rocket_ammo -= 1
		if rocket_ammo > 0:
			rocketAttackTimer.start()
		else:
			rocketAttackTimer.stop()

func _on_plasma_timer_timeout():
	plasma_ammo += plasma_baseammo + additional_attacks
	plasmaAttackTimer.start()

func _on_plasma_attack_timer_timeout():
	if plasma_ammo > 0:
		var plasma_attack = plasma.instantiate()
		plasma_attack.position = position
		plasma_attack.level = plasma_level
		plasmaBase.add_child(plasma_attack)
		plasma_ammo -= 1
		if plasma_ammo > 0:
			plasmaAttackTimer.start()
		else:
			plasmaAttackTimer.stop()

func spawn_plasma():
	var get_plasma_total = plasmaBase.get_child_count()
	var calc_spawns = (plasma_ammo + additional_attacks) - get_plasma_total
	while calc_spawns > 0:
		var plasma_spawn = plasma.instantiate()
		plasma_spawn.global_position = global_position
		plasmaBase.add_child(plasma_spawn)
		calc_spawns -= 1
	var get_plasmas = plasmaBase.get_children()
	for i in get_plasmas:
		if i.has_method("update_plasma"):
			i.update_plasma()

func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


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


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)


func _on_grab_area_area_entered(area):
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	if area.is_in_group("loot"):
		var gem_exp = area.collect()
		calculate_experience(gem_exp)

func calculate_experience(gem_exp):
	var exp_required = calculate_experiencecap()
	collected_experience += gem_exp
	if experience + collected_experience >= exp_required: # level up
		collected_experience -= exp_required - experience
		experience_level += 1
		experience = 0
		exp_required = calculate_experiencecap()
		levelup()
	else:
		experience += collected_experience
		collected_experience = 0
	
	set_expbar(experience, exp_required)

func calculate_experiencecap():
	var exp_cap = experience_level
	if experience_level < 20:
		exp_cap = experience_level * 5
	elif experience_level < 40:
		exp_cap = 95 + (experience_level - 19) * 8
	else:
		exp_cap = 255 + (experience_level - 39) * 12
		
	return exp_cap
		
func set_expbar(set_value = 1, set_max_value = 100):
	expBar.value = set_value
	expBar.max_value = set_max_value

func levelup():
	sndLevelUp.play()
	lblLevel.text = str("Level: ", experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel, "position", Vector2(220, 50), 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true

func upgrade_character(upgrade):
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
			max_speed += 20.0
			accel += 20.0
			decel += 20.0
			damping += 10.0
		"thick1", "thick2", "thick3", "thick4":
			spell_size += 0.10
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
	
func get_random_item():
	var dblist = []
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
		return null

func change_time(argtime = 0):
	time = argtime
	var get_m = int(time / 60.0)
	var get_s = time % 60
	if get_m < 10:
		get_m = str(0, get_m)
	if get_s < 10:
		get_s = str(0, get_s)
	lblTimer.text = str(get_m, ":", get_s)

func adjust_gui_collection(upgrade):
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

func death():
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


func _on_btn_menu_click_end():
	get_tree().paused = false
	var _level = get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
