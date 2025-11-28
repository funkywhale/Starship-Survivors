extends Node

const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"

const UPGRADE_EFFECTS = {
	"armor": {"stat": "armor", "value": 1, "max_level": 5},
	"damage": {"stat": "damage_bonus", "values": [3, 3, 3, 3, 3]},
	"speed": {"stat": "max_speed", "value": 10.0, "extra": {"accel": 1.0, "decel": 10.0, "damping": 10.0}, "max_level": 5},
	"thick": {"stat": "spell_size", "value": 0.20, "max_level": 5},
	"firerate": {"stat": "spell_cooldown", "value": 0.1, "max_level": 5},
	"weapon": {"stat": "additional_attacks", "value": 1, "max_level": 3},
	"pickup": {"stat": "pickup_range_multiplier", "values": [1.25, 1.50, 1.75, 2.00, 2.50], "levels": [1, 2, 3, 4, 5]},
	"knockback": {"stat": "knockback_multiplier", "value": 0.10, "max_level": 5},
	"projectilespeed": {"stat": "projectile_speed_multiplier", "value": 0.10, "max_level": 5},
	"critical": {"stat": "critical_chance", "value": 0.05, "max_level": 5},
	"knowledge": {"stat": "experience_multiplier", "value": 0.10, "max_level": 5},
	"heal": {"stat": "hp", "value": 20}
}

const UPGRADES = {
	"armor1": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces damage taken by 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces damage taken by an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces damage taken by an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces damage taken by an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"armor5": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces damage taken by an additional 1 point",
		"level": "Level: 5",
		"prerequisite": ["armor4"],
		"type": "upgrade"
	},
	"damage1": {
		"icon": ICON_PATH + "damage.png",
		"displayname": "Damage",
		"details": "+3 damage to all weapons",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"damage2": {
		"icon": ICON_PATH + "damage.png",
		"displayname": "Damage",
		"details": "+3 additional damage to all weapons",
		"level": "Level: 2",
		"prerequisite": ["damage1"],
		"type": "upgrade"
	},
	"damage3": {
		"icon": ICON_PATH + "damage.png",
		"displayname": "Damage",
		"details": "+3 additional damage to all weapons",
		"level": "Level: 3",
		"prerequisite": ["damage2"],
		"type": "upgrade"
	},
	"damage4": {
		"icon": ICON_PATH + "damage.png",
		"displayname": "Damage",
		"details": "+3 additional damage to all weapons",
		"level": "Level: 4",
		"prerequisite": ["damage3"],
		"type": "upgrade"
	},
	"damage5": {
		"icon": ICON_PATH + "damage.png",
		"displayname": "Damage",
		"details": "+3 additional damage to all weapons",
		"level": "Level: 5",
		"prerequisite": ["damage4"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement speed Increased by 25%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement speed Increased by an additional 25%",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement speed Increased by an additional 25%",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement speed Increased an additional 25%",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"speed5": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement speed Increased an additional 25%",
		"level": "Level: 5",
		"prerequisite": ["speed4"],
		"type": "upgrade"
	},
	"thick1": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 20%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"thick2": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 20%",
		"level": "Level: 2",
		"prerequisite": ["thick1"],
		"type": "upgrade"
	},
	"thick3": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 20%",
		"level": "Level: 3",
		"prerequisite": ["thick2"],
		"type": "upgrade"
	},
	"thick4": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 20%",
		"level": "Level: 4",
		"prerequisite": ["thick3"],
		"type": "upgrade"
	},
	"thick5": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 20%",
		"level": "Level: 5",
		"prerequisite": ["thick4"],
		"type": "upgrade"
	},
	"firerate1": {
		"icon": ICON_PATH + "firing_rate.png",
		"displayname": "Firing Rate",
		"details": "Increases fire rate by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"firerate2": {
		"icon": ICON_PATH + "firing_rate.png",
		"displayname": "Firing Rate",
		"details": "Increases fire rate by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["firerate1"],
		"type": "upgrade"
	},
	"firerate3": {
		"icon": ICON_PATH + "firing_rate.png",
		"displayname": "Firing Rate",
		"details": "Increases fire rate by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["firerate2"],
		"type": "upgrade"
	},
	"firerate4": {
		"icon": ICON_PATH + "firing_rate.png",
		"displayname": "Firing Rate",
		"details": "Increases fire rate by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["firerate3"],
		"type": "upgrade"
	},
	"firerate5": {
		"icon": ICON_PATH + "firing_rate.png",
		"displayname": "Firing Rate",
		"details": "Increases fire rate by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["firerate4"],
		"type": "upgrade"
	},
	"weapon1": {
		"icon": ICON_PATH + "weapon_bay.png",
		"displayname": "Weapon Bay",
		"details": "Your weapons now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"weapon2": {
		"icon": ICON_PATH + "weapon_bay.png",
		"displayname": "Weapon Bay",
		"details": "Your weapons now spawn 1 more additional attack",
		"level": "Level: 2",
		"prerequisite": ["weapon1"],
		"type": "upgrade"
	},
	"weapon3": {
		"icon": ICON_PATH + "weapon_bay.png",
		"displayname": "Weapon Bay",
		"details": "Your weapons now spawn 1 more additional attack",
		"level": "Level: 3",
		"prerequisite": ["weapon2"],
		"type": "upgrade"
	},
	"heal": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Heal",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	},
	"pickup1": {
		"icon": ICON_PATH + "pickup.png",
		"displayname": "Pickup Range",
		"details": "Increases pickup radius by 25%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"pickup2": {
		"icon": ICON_PATH + "pickup.png",
		"displayname": "Pickup Range",
		"details": "Increases pickup radius by 50%",
		"level": "Level: 2",
		"prerequisite": ["pickup1"],
		"type": "upgrade"
	},
	"pickup3": {
		"icon": ICON_PATH + "pickup.png",
		"displayname": "Pickup Range",
		"details": "Increases pickup radius by 75%",
		"level": "Level: 3",
		"prerequisite": ["pickup2"],
		"type": "upgrade"
	},
	"pickup4": {
		"icon": ICON_PATH + "pickup.png",
		"displayname": "Pickup Range",
		"details": "Increases pickup radius by 100%",
		"level": "Level: 4",
		"prerequisite": ["pickup3"],
		"type": "upgrade"
	},
	"pickup5": {
		"icon": ICON_PATH + "pickup.png",
		"displayname": "Pickup Range",
		"details": "Increases pickup radius by 150%",
		"level": "Level: 5",
		"prerequisite": ["pickup4"],
		"type": "upgrade"
	},
	"knockback1": {
		"icon": ICON_PATH + "knockback.png",
		"displayname": "Knockback",
		"details": "Increases weapon knockback by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"knockback2": {
		"icon": ICON_PATH + "knockback.png",
		"displayname": "Knockback",
		"details": "Increases weapon knockback by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["knockback1"],
		"type": "upgrade"
	},
	"knockback3": {
		"icon": ICON_PATH + "knockback.png",
		"displayname": "Knockback",
		"details": "Increases weapon knockback by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["knockback2"],
		"type": "upgrade"
	},
	"knockback4": {
		"icon": ICON_PATH + "knockback.png",
		"displayname": "Knockback",
		"details": "Increases weapon knockback by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["knockback3"],
		"type": "upgrade"
	},
	"knockback5": {
		"icon": ICON_PATH + "knockback.png",
		"displayname": "Knockback",
		"details": "Increases weapon knockback by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["knockback4"],
		"type": "upgrade"
	},
	"projectilespeed1": {
		"icon": ICON_PATH + "projectilespeed.png",
		"displayname": "Projectile Speed",
		"details": "Increases projectile speed by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"projectilespeed2": {
		"icon": ICON_PATH + "projectilespeed.png",
		"displayname": "Projectile Speed",
		"details": "Increases projectile speed by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["projectilespeed1"],
		"type": "upgrade"
	},
	"projectilespeed3": {
		"icon": ICON_PATH + "projectilespeed.png",
		"displayname": "Projectile Speed",
		"details": "Increases projectile speed by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["projectilespeed2"],
		"type": "upgrade"
	},
	"projectilespeed4": {
		"icon": ICON_PATH + "projectilespeed.png",
		"displayname": "Projectile Speed",
		"details": "Increases projectile speed by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["projectilespeed3"],
		"type": "upgrade"
	},
	"projectilespeed5": {
		"icon": ICON_PATH + "projectilespeed.png",
		"displayname": "Projectile Speed",
		"details": "Increases projectile speed by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["projectilespeed4"],
		"type": "upgrade"
	},
	"critical1": {
		"icon": ICON_PATH + "critical.png",
		"displayname": "Critical Strike",
		"details": "5% chance to deal double damage",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"critical2": {
		"icon": ICON_PATH + "critical.png",
		"displayname": "Critical Strike",
		"details": "10% chance to deal double damage",
		"level": "Level: 2",
		"prerequisite": ["critical1"],
		"type": "upgrade"
	},
	"critical3": {
		"icon": ICON_PATH + "critical.png",
		"displayname": "Critical Strike",
		"details": "15% chance to deal double damage",
		"level": "Level: 3",
		"prerequisite": ["critical2"],
		"type": "upgrade"
	},
	"critical4": {
		"icon": ICON_PATH + "critical.png",
		"displayname": "Critical Strike",
		"details": "20% chance to deal double damage",
		"level": "Level: 4",
		"prerequisite": ["critical3"],
		"type": "upgrade"
	},
	"critical5": {
		"icon": ICON_PATH + "critical.png",
		"displayname": "Critical Strike",
		"details": "25% chance to deal double damage",
		"level": "Level: 5",
		"prerequisite": ["critical4"],
		"type": "upgrade"
	},
	"knowledge1": {
		"icon": ICON_PATH + "knowledge.png",
		"displayname": "Knowledge",
		"details": "Increases experience gain by 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"knowledge2": {
		"icon": ICON_PATH + "knowledge.png",
		"displayname": "Knowledge",
		"details": "Increases experience gain by an additional 10%",
		"level": "Level: 2",
		"prerequisite": ["knowledge1"],
		"type": "upgrade"
	},
	"knowledge3": {
		"icon": ICON_PATH + "knowledge.png",
		"displayname": "Knowledge",
		"details": "Increases experience gain by an additional 10%",
		"level": "Level: 3",
		"prerequisite": ["knowledge2"],
		"type": "upgrade"
	},
	"knowledge4": {
		"icon": ICON_PATH + "knowledge.png",
		"displayname": "Knowledge",
		"details": "Increases experience gain by an additional 10%",
		"level": "Level: 4",
		"prerequisite": ["knowledge3"],
		"type": "upgrade"
	},
	"knowledge5": {
		"icon": ICON_PATH + "knowledge.png",
		"displayname": "Knowledge",
		"details": "Increases experience gain by an additional 10%",
		"level": "Level: 5",
		"prerequisite": ["knowledge4"],
		"type": "upgrade"
	},
}

func get_upgrade_data(upgrade_id: String) -> Dictionary:
	if WeaponRegistry.is_weapon_upgrade(upgrade_id):
		return WeaponRegistry.get_weapon_upgrade_data(upgrade_id)
	
	if upgrade_id in UPGRADES:
		return UPGRADES[upgrade_id]
	
	return {}

func get_all_upgrade_ids() -> Array:
	var all_ids: Array = []
	
	for weapon_id in WeaponRegistry.WEAPONS.keys():
		for level in range(1, 9):
			all_ids.append(weapon_id + str(level))
	
	for upgrade_id in UPGRADES.keys():
		all_ids.append(upgrade_id)
	
	return all_ids

func get_upgrade_effect(upgrade_id: String) -> Dictionary:
	var base_type = ""
	var level = 0
	
	if upgrade_id == "heal":
		return UPGRADE_EFFECTS["heal"]
	
	for upgrade_type in UPGRADE_EFFECTS.keys():
		if upgrade_id.begins_with(upgrade_type):
			base_type = upgrade_type
			var num_str = upgrade_id.substr(upgrade_type.length())
			if num_str.is_valid_int():
				level = int(num_str)
			break
	
	if base_type.is_empty():
		return {}
	
	var effect = UPGRADE_EFFECTS[base_type].duplicate()
	effect["level"] = level
	effect["base_type"] = base_type
	
	if effect.has("values"):
		if level > 0 and level <= effect.values.size():
			effect["value"] = effect.values[level - 1]
	
	return effect

func apply_upgrade_to_player(player: Node, upgrade_id: String) -> void:
	var effect = get_upgrade_effect(upgrade_id)
	if effect.is_empty():
		return
	
	var stat = effect.get("stat", "")
	var value = effect.get("value", 0)
	
	if stat.is_empty():
		return
	
	match stat:
		"armor":
			player.armor += value
		"damage_bonus":
			player.damage_bonus += value
		"max_speed":
			player.max_speed += value
			if effect.has("extra"):
				for extra_stat in effect.extra:
					player.set(extra_stat, player.get(extra_stat) + effect.extra[extra_stat])
		"spell_size":
			player.spell_size += value
		"spell_cooldown":
			player.spell_cooldown += value
		"additional_attacks":
			player.additional_attacks += value
		"pickup_range_multiplier":
			player.pickup_range_level = effect.level
			player.pickup_range_multiplier = value
			if player.has_method("_update_pickup_radii"):
				player._update_pickup_radii()
		"knockback_multiplier":
			player.knockback_multiplier += value
		"projectile_speed_multiplier":
			player.projectile_speed_multiplier += value
		"critical_chance":
			player.critical_chance += value
		"experience_multiplier":
			player.experience_multiplier += value
		"hp":
			player.hp += value
			player.hp = clamp(player.hp, 0, player.maxhp)
			if player.has_node("%HealthBar"):
				var health_bar = player.get_node("%HealthBar")
				health_bar.max_value = player.maxhp
				health_bar.value = player.hp
