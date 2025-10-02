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
		"details": "Pulse laser now pass through enemies. +1 additional pulse laser is fired",
		"level": "Level: 3",
		"prerequisite": ["pulselaser2"],
		"type": "weapon"
	},
	"pulselaser4": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "+3 damage and +1 additional pulse laser is fired",
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
		"details": "+1 aditional plasma blast is fired",
		"level": "Level: 2",
		"prerequisite": ["plasma1"],
		"type": "weapon"
	},
	"plasma3": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 aditional plasma blast is fired",
		"level": "Level: 3",
		"prerequisite": ["plasma2"],
		"type": "weapon"
	},
	"plasma4": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 aditional plasma blast is fired",
		"level": "Level: 4",
		"prerequisite": ["plasma3"],
		"type": "weapon"
	},
	"rocket1": {
		"icon": WEAPON_PATH + "rocket.png",
		"displayname": "Rocket",
		"details": "A rocket is launched and heads somewhere in the player's direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"rocket2": {
		"icon": WEAPON_PATH + "rocket.png",
		"displayname": "Rocket",
		"details": "An additional Rocket is created",
		"level": "Level: 2",
		"prerequisite": ["rocket1"],
		"type": "weapon"
	},
	"rocket3": {
		"icon": WEAPON_PATH + "rocket.png",
		"displayname": "Rocket",
		"details": "The Rocket cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["rocket2"],
		"type": "weapon"
	},
	"rocket4": {
		"icon": WEAPON_PATH + "rocket.png",
		"displayname": "Rocket",
		"details": "An additional Rocket is created and the knockback is increased by 25%",
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
		"details": "Movement Speed Increased by 50%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement Speed Increased by an additional 50%",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement Speed Increased by an additional 50%",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "thrusters.png",
		"displayname": "Thrusters",
		"details": "Movement Speed Increased an additional 50%",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"thick1": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 10%",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"thick2": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 10%",
		"level": "Level: 2",
		"prerequisite": ["thick1"],
		"type": "upgrade"
	},
	"thick3": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 10%",
		"level": "Level: 3",
		"prerequisite": ["thick2"],
		"type": "upgrade"
	},
	"thick4": {
		"icon": ICON_PATH + "plasma_reactor.png",
		"displayname": "Reactor",
		"details": "Increases the size of weapons 10%",
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
		"details": "Your weapons now spawn an additional attack",
		"level": "Level: 2",
		"prerequisite": ["weapon1"],
		"type": "upgrade"
	},
	"heal": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Heal",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}
