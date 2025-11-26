extends Node


const ICON_PATH = "res://Textures/Items/Upgrades/"
const WEAPON_PATH = "res://Textures/Items/Weapons/"
const UPGRADES = {
	"pulselaser1": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "A pulse laser fires at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"pulselaser2": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "+1 additional pulse laser is fired",
		"level": "Level: 2",
		"prerequisite": ["pulselaser1"],
		"type": "weapon"
	},
	"pulselaser3": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "Pulse laser pierces. +1 additional pulse laser is fired and +5 damage",
		"level": "Level: 3",
		"prerequisite": ["pulselaser2"],
		"type": "weapon"
	},
	"pulselaser4": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "Can pierce through 4 enemies. +3 additional pulse lasers are fired",
		"level": "Level: 4",
		"prerequisite": ["pulselaser3"],
		"type": "weapon"
	},
	"plasma1": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "A plasma blast that pierces enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"plasma2": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired",
		"level": "Level: 2",
		"prerequisite": ["plasma1"],
		"type": "weapon"
	},
	"plasma3": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired",
		"level": "Level: 3",
		"prerequisite": ["plasma2"],
		"type": "weapon"
	},
	"plasma4": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired",
		"level": "Level: 4",
		"prerequisite": ["plasma3"],
		"type": "weapon"
	},
	"rocket1": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "A rocket is launched and heads somewhere in the player's direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"rocket2": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "An additional Rocket is created. +5 damage",
		"level": "Level: 2",
		"prerequisite": ["rocket1"],
		"type": "weapon"
	},
	"rocket3": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "The Rocket cooldown is reduced by 0.5 seconds. +5 damage",
		"level": "Level: 3",
		"prerequisite": ["rocket2"],
		"type": "weapon"
	},
	"rocket4": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "An additional Rocket is created. +5 damage and +25% knockback",
		"level": "Level: 4",
		"prerequisite": ["rocket3"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"ionlaser1": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "Fires a growing beam of plasma energy that pierces enemies",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"ionlaser2": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+5 damage, +25% range, and 12% faster firing rate",
		"level": "Level: 2",
		"prerequisite": ["ionlaser1"],
		"type": "weapon"
	},
	"ionlaser3": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+10 damage, +50% range, and 24% faster firing rate",
		"level": "Level: 3",
		"prerequisite": ["ionlaser2"],
		"type": "weapon"
	},
	"ionlaser4": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+15 damage, +100% range, and 36% faster firing rate",
		"level": "Level: 4",
		"prerequisite": ["ionlaser3"],
		"type": "weapon"
	},
	"armor2": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
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
	"scattershot1": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 3 pellets in a cone. Shotgun-style weapon.",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"scattershot2": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 5 pellets. Damage increased to 7 and can penetrate 2 enemies",
		"level": "Level: 2",
		"prerequisite": ["scattershot1"],
		"type": "weapon"
	},
	"scattershot3": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 7 pellets. Damage increased to 9 and can penetrate 3 enemies",
		"level": "Level: 3",
		"prerequisite": ["scattershot2"],
		"type": "weapon"
	},
	"scattershot4": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 9 pellets. Damage increased to 12 and can penetrate 4 enemies",
		"level": "Level: 4",
		"prerequisite": ["scattershot3"],
		"type": "weapon"
	},
	"heal": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Heal",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	},
}
