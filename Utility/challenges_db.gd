extends Node

# Challenge definition structure
# id: unique string
# description: string
# type: "kill_count" | "survival_time" | "weapon_upgrade"
# target: int (number required)
# unlocks: array of ship/weapon ids

const CHALLENGES = [
	{
		"id": "kill_500_enemies",
		"description": "Kill 500 enemies in a single run.",
		"type": "kill_count",
		"target": 500,
		"unlocks": ["ship_3", "plasma_icon"]
	},
	{
		"id": "survive_5_minutes",
		"description": "Survive for at least 5:00 minutes.",
		"type": "survival_time",
		"target": 300,
		"unlocks": ["ship_4", "scattershot_icon"]
	},
	{
		"id": "upgrade_weapon_level_8",
		"description": "Fully upgrade any weapon to level 8.",
		"type": "weapon_upgrade",
		"target": 8,
		"unlocks": ["ship_5", "ion_laser_icon"]
	}
]

func get_challenges():
	return CHALLENGES

func get_challenge_by_id(id: String):
	for c in CHALLENGES:
		if c["id"] == id:
			return c
	return null
