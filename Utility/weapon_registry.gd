extends Node

const WEAPON_PATH = "res://Textures/Items/Weapons/"

const WEAPONS = {
	"pulselaser": {
		"scene": preload("res://Player/Attack/pulse_laser.tscn"),
		"base_cooldown": 1.5,
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"level_descriptions": [
			"A pulse laser fires at a random enemy",
			"+1 ammo, +5 damage",
			"+1 ammo, pierces 2 enemies",
			"+1 ammo, +5 damage, pierces 2 enemies",
			"+2 ammo, +5 damage, pierces 3 enemies, +5% speed",
			"+2 ammo, +5 damage, +10% speed, 10% knockback",
			"+2 ammo, +15% speed, 15% knockback",
			"+3 ammo, +10 damage, +20% speed, pierces 5 enemies, 20% knockback"
		],
		"prerequisites": [
			[],
			["pulselaser1"],
			["pulselaser2"],
			["pulselaser3"],
			["pulselaser4"],
			["pulselaser5"],
			["pulselaser6"],
			["pulselaser7"]
		],
		"levels": [
			# Level 1
			{"ammo": 1, "damage": 10, "speed": 100, "hp": 1, "size": 1.0, "knockback": 50},
			# Level 2
			{"ammo": 2, "damage": 15, "speed": 100, "hp": 1, "size": 1.0, "knockback": 50},
			# Level 3 
			{"ammo": 3, "damage": 15, "speed": 100, "hp": 2, "size": 1.0, "knockback": 50},
			# Level 4
			{"ammo": 4, "damage": 20, "speed": 100, "hp": 2, "size": 1.0, "knockback": 50},
			# Level 5
			{"ammo": 6, "damage": 25, "speed": 105, "hp": 3, "size": 1.05, "knockback": 55},
			# Level 6
			{"ammo": 8, "damage": 30, "speed": 110, "hp": 3, "size": 1.1, "knockback": 60},
			# Level 7
			{"ammo": 10, "damage": 30, "speed": 115, "hp": 3, "size": 1.15, "knockback": 65},
			# Level 8
			{"ammo": 13, "damage": 40, "speed": 120, "hp": 5, "size": 1.2, "knockback": 70},
		]
	},
	"rocket": {
		"scene": preload("res://Player/Attack/rocket.tscn"),
		"base_cooldown": 3.0,
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"level_descriptions": [
			"A rocket is launched and heads somewhere in the player's direction",
			"+1 ammo, +5 damage",
			"+5 damage, 0.25s faster cooldown",
			"+1 ammo, +5 damage, +10 speed, 25% knockback",
			"+5 damage, +15 speed, 0.25s faster cooldown",
			"+1 ammo, +20 speed, 30% knockback",
			"+5 damage, +25 speed, 35% knockback",
			"+2 ammo, +30 speed, 40% knockback, 0.5s faster cooldown"
		],
		"prerequisites": [
			[],
			["rocket1"],
			["rocket2"],
			["rocket3"],
			["rocket4"],
			["rocket5"],
			["rocket6"],
			["rocket7"]
		],
		"levels": [
			# Level 1
			{"ammo": 1, "damage": 10, "speed": 140, "size": 1.0, "knockback": 100, "explosion_radius": 30.0, "explosion_damage": 10},
			# Level 2
			{"ammo": 2, "damage": 15, "speed": 140, "size": 1.0, "knockback": 100, "explosion_radius": 30.0, "explosion_damage": 15},
			# Level 3 
			{"ammo": 2, "damage": 25, "speed": 140, "size": 1.0, "knockback": 100, "explosion_radius": 35.0, "explosion_damage": 25, "cooldown_modifier": - 0.25},
			# Level 4
			{"ammo": 3, "damage": 25, "speed": 150, "size": 1.0, "knockback": 125, "explosion_radius": 35.0, "explosion_damage": 25},
			# Level 5 
			{"ammo": 3, "damage": 30, "speed": 155, "size": 1.0, "knockback": 125, "explosion_radius": 45.0, "explosion_damage": 30, "cooldown_modifier": - 0.25},
			# Level 6
			{"ammo": 4, "damage": 30, "speed": 160, "size": 1.0, "knockback": 130, "explosion_radius": 45.0, "explosion_damage": 30},
			# Level 7 
			{"ammo": 4, "damage": 35, "speed": 165, "size": 1.0, "knockback": 135, "explosion_radius": 45.0, "explosion_damage": 35},
			# Level 8
			{"ammo": 6, "damage": 35, "speed": 170, "size": 1.0, "knockback": 140, "explosion_radius": 45.0, "explosion_damage": 35, "cooldown_modifier": - 0.50},
		]
	},
	"plasma": {
		"scene": preload("res://Player/Attack/plasma.tscn"),
		"base_cooldown": 4.0,
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"level_descriptions": [
			"A plasma blast that pierces enemies",
			"+1 ammo, pierces 4 enemies, trail damage 10",
			"+10 damage, pierces 5 enemies",
			"+1 ammo, pierces 6 enemies, trail damage 15",
			"+1 ammo, +10 damage, pierces 7 enemies",
			"+10 damage, pierces 8 enemies, trail damage 20",
			"+1 ammo, pierces 9 enemies",
			"+3 ammo, +15 damage, +40 speed, 20% size, pierces 11 enemies, trail damage 25"
		],
		"prerequisites": [
			[],
			["plasma1"],
			["plasma2"],
			["plasma3"],
			["plasma4"],
			["plasma5"],
			["plasma6"],
			["plasma7"]
		],
		"levels": [
			# Level 1
			{"ammo": 1, "hp": 3, "damage": 15, "speed": 140, "size": 1.0, "trail_damage": 5},
			# Level 2
			{"ammo": 2, "hp": 4, "damage": 15, "speed": 140, "size": 1.0, "trail_damage": 10},
			# Level 3
			{"ammo": 2, "hp": 5, "damage": 25, "speed": 140, "size": 1.0, "trail_damage": 10},
			# Level 4
			{"ammo": 3, "hp": 6, "damage": 25, "speed": 140, "size": 1.0, "trail_damage": 15},
			# Level 5
			{"ammo": 4, "hp": 7, "damage": 35, "speed": 140, "size": 1.0, "trail_damage": 15},
			# Level 6
			{"ammo": 4, "hp": 8, "damage": 45, "speed": 140, "size": 1.0, "trail_damage": 20},
			# Level 7
			{"ammo": 5, "hp": 9, "damage": 45, "speed": 140, "size": 1.0, "trail_damage": 20},
			# Level 8
			{"ammo": 8, "hp": 11, "damage": 60, "speed": 180, "size": 1.2, "trail_damage": 25},
		]
	},
	"scattershot": {
		"scene": preload("res://Player/Attack/scatter_shot.tscn"),
		"base_cooldown": 2.0,
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"level_descriptions": [
			"Fires 3 pellets in a cone. Shotgun-style weapon.",
			"4 shots, 5% faster cooldown",
			"5 shots, +3 damage, pierces 2 enemies, 10% faster cooldown",
			"6 shots, pierces 2 enemies, 15% faster cooldown",
			"7 shots, +5 damage, pierces 3 enemies, 20% faster cooldown",
			"8 shots, pierces 3 enemies, 25% faster cooldown",
			"9 shots, +7 damage, pierces 4 enemies, 35% faster cooldown",
			"10 shots, +10 damage, pierces 5 enemies, 50% faster cooldown"
		],
		"prerequisites": [
			[],
			["scattershot1"],
			["scattershot2"],
			["scattershot3"],
			["scattershot4"],
			["scattershot5"],
			["scattershot6"],
			["scattershot7"]
		],
		"levels": [
			# Level 1
			{"pellets": 3, "damage": 10, "hp": 1, "speed": 200, "size": 1.0},
			# Level 2
			{"pellets": 4, "damage": 10, "hp": 1, "speed": 200, "size": 1.0, "cooldown_modifier": - 0.1},
			# Level 3
			{"pellets": 5, "damage": 13, "hp": 2, "speed": 200, "size": 1.0, "cooldown_modifier": - 0.2},
			# Level 4
			{"pellets": 6, "damage": 13, "hp": 2, "speed": 200, "size": 1.0, "cooldown_modifier": - 0.3},
			# Level 5
			{"pellets": 7, "damage": 18, "hp": 3, "speed": 200, "size": 1.0, "cooldown_modifier": - 0.4},
			# Level 6
			{"pellets": 8, "damage": 18, "hp": 3, "speed": 200, "size": 1.0, "cooldown_modifier": - 0.5},
			# Level 7
			{"pellets": 9, "damage": 25, "hp": 4, "speed": 200, "size": 1.0, "cooldown_modifier": - 0.7},
			# Level 8
			{"pellets": 10, "damage": 35, "hp": 5, "speed": 200, "size": 1.0, "cooldown_modifier": - 1.0},
		]
	},
	"ionlaser": {
		"scene": preload("res://Player/Attack/ion_laser_beam.tscn"),
		"base_cooldown": 2.5,
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"level_descriptions": [
			"Fires a growing beam of plasma energy that pierces enemies",
			"+5 damage, +25% range, 8% faster cooldown",
			"+10 damage, +50% range, 16% faster cooldown",
			"+5 damage, +100% range, 24% faster cooldown",
			"+5 damage, +125% range, 5% size, 32% faster cooldown",
			"+5 damage, +150% range, 40% faster cooldown",
			"+10 damage, +175% range, 10% size, 48% faster cooldown",
			"+20 damage, +200% range, 20% size, 60% faster cooldown"
		],
		"prerequisites": [
			[],
			["ionlaser1"],
			["ionlaser2"],
			["ionlaser3"],
			["ionlaser4"],
			["ionlaser5"],
			["ionlaser6"],
			["ionlaser7"]
		],
		"levels": [
			# Level 1
			{"ammo": 1, "damage": 10, "max_length": 100.0, "attack_size": 1.0, "grow_speed": 100.0, "cooldown_modifier": 0.0},
			# Level 2 - 
			{"ammo": 1, "damage": 15, "max_length": 125.0, "attack_size": 1.0, "grow_speed": 200.0, "cooldown_modifier": - 0.2},
			# Level 3 - 
			{"ammo": 1, "damage": 25, "max_length": 150.0, "attack_size": 1.0, "grow_speed": 250.0, "cooldown_modifier": - 0.4},
			# Level 4 - 
			{"ammo": 1, "damage": 30, "max_length": 200.0, "attack_size": 1.0, "grow_speed": 300.0, "cooldown_modifier": - 0.6},
			# Level 5 - 
			{"ammo": 1, "damage": 35, "max_length": 225.0, "attack_size": 1.05, "grow_speed": 325.0, "cooldown_modifier": - 0.8},
			# Level 6 - 
			{"ammo": 1, "damage": 40, "max_length": 250.0, "attack_size": 1.05, "grow_speed": 350.0, "cooldown_modifier": - 1.0},
			# Level 7 -
			{"ammo": 1, "damage": 50, "max_length": 275.0, "attack_size": 1.1, "grow_speed": 375.0, "cooldown_modifier": - 1.2},
			# Level 8 -
			{"ammo": 1, "damage": 70, "max_length": 300.0, "attack_size": 1.2, "grow_speed": 400.0, "cooldown_modifier": - 1.5},
		]
	}
}

func get_weapon_stats(weapon_id: String, level: int) -> Dictionary:
	if not weapon_id in WEAPONS:
		push_error("WeaponRegistry: Unknown weapon_id '%s'" % weapon_id)
		return {}
	
	var weapon_data = WEAPONS[weapon_id]
	var level_index = clamp(level - 1, 0, weapon_data.levels.size() - 1)
	
	return weapon_data.levels[level_index].duplicate()

func get_base_cooldown(weapon_id: String) -> float:
	if not weapon_id in WEAPONS:
		push_error("WeaponRegistry: Unknown weapon_id '%s'" % weapon_id)
		return 1.0
	
	return WEAPONS[weapon_id].base_cooldown

func get_weapon_scene(weapon_id: String) -> PackedScene:
	if not weapon_id in WEAPONS:
		push_error("WeaponRegistry: Unknown weapon_id '%s'" % weapon_id)
		return null
	
	return WEAPONS[weapon_id].scene

func get_effective_cooldown(weapon_id: String, level: int, spell_cooldown_modifier: float) -> float:
	var base = get_base_cooldown(weapon_id)
	var stats = get_weapon_stats(weapon_id, level)
	
	if stats.has("cooldown_modifier"):
		base += stats.cooldown_modifier
	
	return base * (1.0 - spell_cooldown_modifier)

func get_weapon_upgrade_data(upgrade_id: String) -> Dictionary:
	var weapon_id = ""
	var level = 0
	
	for wid in WEAPONS.keys():
		if upgrade_id.begins_with(wid):
			weapon_id = wid
			var num_str = upgrade_id.substr(wid.length())
			if num_str.is_valid_int():
				level = int(num_str)
			break
	
	if weapon_id.is_empty() or level < 1:
		return {}
	
	var weapon = WEAPONS[weapon_id]
	var level_index = clamp(level - 1, 0, weapon.level_descriptions.size() - 1)
	
	return {
		"icon": weapon.icon,
		"displayname": weapon.displayname,
		"details": weapon.level_descriptions[level_index],
		"level": "Level: %d" % level,
		"prerequisite": weapon.prerequisites[level_index],
		"type": "weapon"
	}

func is_weapon_upgrade(upgrade_id: String) -> bool:
	for weapon_id in WEAPONS.keys():
		if upgrade_id.begins_with(weapon_id):
			return true
	return false
