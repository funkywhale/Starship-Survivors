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
		"details": "+1 additional pulse laser is fired",
		"level": "Level: 4",
		"prerequisite": ["pulselaser3"],
		"type": "weapon"
	},
	"pulselaser5": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "+1 additional pulse laser is fired. +5 damage",
		"level": "Level: 5",
		"prerequisite": ["pulselaser4"],
		"type": "weapon"
	},
	"pulselaser6": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "+1 additional pulse laser is fired. +5 damage",
		"level": "Level: 6",
		"prerequisite": ["pulselaser5"],
		"type": "weapon"
	},
	"pulselaser7": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "+1 additional pulse laser is fired. Can pierce through 5 enemies",
		"level": "Level: 7",
		"prerequisite": ["pulselaser6"],
		"type": "weapon"
	},
	"pulselaser8": {
		"icon": WEAPON_PATH + "pulse_laser.png",
		"displayname": "Pulse Laser",
		"details": "+2 additional pulse lasers are fired. +10 damage and can pierce through 6 enemies",
		"level": "Level: 8",
		"prerequisite": ["pulselaser7"],
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
	"plasma5": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired. +5 damage",
		"level": "Level: 5",
		"prerequisite": ["plasma4"],
		"type": "weapon"
	},
	"plasma6": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired. +5 damage",
		"level": "Level: 6",
		"prerequisite": ["plasma5"],
		"type": "weapon"
	},
	"plasma7": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired. +10 damage",
		"level": "Level: 7",
		"prerequisite": ["plasma6"],
		"type": "weapon"
	},
	"plasma8": {
		"icon": WEAPON_PATH + "plasma_icon.png",
		"displayname": "Plasma Blast",
		"details": "+1 additional plasma blast is fired. +15 damage and increased speed",
		"level": "Level: 8",
		"prerequisite": ["plasma7"],
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
		"details": "+1 additional rocket is fired. +5 damage",
		"level": "Level: 4",
		"prerequisite": ["rocket3"],
		"type": "weapon"
	},
	"rocket5": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "The Rocket cooldown is reduced by 0.25 seconds. +5 damage",
		"level": "Level: 5",
		"prerequisite": ["rocket4"],
		"type": "weapon"
	},
	"rocket6": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "+1 additional rocket is fired. +10 damage",
		"level": "Level: 6",
		"prerequisite": ["rocket5"],
		"type": "weapon"
	},
	"rocket7": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "The Rocket cooldown is reduced by 0.25 seconds. +10 damage",
		"level": "Level: 7",
		"prerequisite": ["rocket6"],
		"type": "weapon"
	},
	"rocket8": {
		"icon": WEAPON_PATH + "storm_shadow.png",
		"displayname": "Rocket",
		"details": "+1 additional rocket is fired. +15 damage and +50% knockback",
		"level": "Level: 8",
		"prerequisite": ["rocket7"],
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
		"details": "+5 damage, +12.5% range, and 4% faster firing rate",
		"level": "Level: 4",
		"prerequisite": ["ionlaser3"],
		"type": "weapon"
	},
	"ionlaser5": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+5 damage, +25% range, and 4% faster firing rate",
		"level": "Level: 5",
		"prerequisite": ["ionlaser4"],
		"type": "weapon"
	},
	"ionlaser6": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+10 damage, +50% range, and 5% faster firing rate",
		"level": "Level: 6",
		"prerequisite": ["ionlaser5"],
		"type": "weapon"
	},
	"ionlaser7": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+10 damage, +75% range, and 10% faster firing rate",
		"level": "Level: 7",
		"prerequisite": ["ionlaser6"],
		"type": "weapon"
	},
	"ionlaser8": {
		"icon": WEAPON_PATH + "ion_laser.png",
		"displayname": "Ion Laser",
		"details": "+15 damage, +125% range, and 11% faster firing rate",
		"level": "Level: 8",
		"prerequisite": ["ionlaser7"],
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
	"armor5": {
		"icon": ICON_PATH + "armor.png",
		"displayname": "Armor Plating",
		"details": "Reduces Damage By an additional 1 point",
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
		"details": "Fires 6 pellets. Damage increased to 8 and can penetrate 2 enemies. Fires 5% faster",
		"level": "Level: 4",
		"prerequisite": ["scattershot3"],
		"type": "weapon"
	},
	"scattershot5": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 7 pellets. Damage increased to 9 and can penetrate 3 enemies. Fires 8% faster",
		"level": "Level: 5",
		"prerequisite": ["scattershot4"],
		"type": "weapon"
	},
	"scattershot6": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 8 pellets. Damage increased to 10 and can penetrate 3 enemies. Fires 10% faster",
		"level": "Level: 6",
		"prerequisite": ["scattershot5"],
		"type": "weapon"
	},
	"scattershot7": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 9 pellets. Damage increased to 11 and can penetrate 4 enemies. Fires 12% faster",
		"level": "Level: 7",
		"prerequisite": ["scattershot6"],
		"type": "weapon"
	},
	"scattershot8": {
		"icon": WEAPON_PATH + "scattershot_icon.png",
		"displayname": "Scatter Shot",
		"details": "Fires 10 pellets. Damage increased to 13 and can penetrate 5 enemies. Fires 16% faster",
		"level": "Level: 8",
		"prerequisite": ["scattershot7"],
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
}
