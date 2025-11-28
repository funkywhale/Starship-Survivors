extends Node

const SAVE_PATH := "user://skins.save"

# all available skins
var skins := {
	"ship_1": {
		"name": "Starfighter Mk I",
		"texture_path": "res://Textures/Player/ship_1.png",
		"starting_weapon": "pulselaser1",
		"hframes": 3,
		"vframes": 1
	},
	"ship_2": {
		"name": "Starfighter Mk II",
		"texture_path": "res://Textures/Player/ship_2.png",
		"starting_weapon": "rocket1",
		"hframes": 3,
		"vframes": 1
	},
	"ship_3": {
		"name": "Skyfeather",
		"texture_path": "res://Textures/Player/ship_3.png",
		"starting_weapon": "plasma1",
		"hframes": 3,
		"vframes": 1
	},
	"ship_4": {
		"name": "Lightning Craft",
		"texture_path": "res://Textures/Player/ship_4.png",
		"starting_weapon": "scattershot1",
		"hframes": 3,
		"vframes": 1
	},
	"ship_5": {
		"name": "Cosmic Serpent",
		"texture_path": "res://Textures/Player/ship_5.png",
		"starting_weapon": "ionlaser1",
		"hframes": 3,
		"vframes": 1
	},
}


# currently equipped skin ID
var equipped: String = "ship_1"

# Challenge requirements for unlocks
var skin_unlock_challenges := {
	"ship_3": "kill_500_enemies",
	"ship_4": "survive_5_minutes",
	"ship_5": "upgrade_weapon_level_8"
}


func _ready() -> void:
	load_data()


func is_skin_unlocked(id: String) -> bool:
	if not skin_unlock_challenges.has(id):
		return true
	var challenge_id = skin_unlock_challenges[id]
	var cm = get_node("/root/challenge_manager")
	return cm.is_completed(challenge_id)

func get_skin_texture_path(id: String) -> String:
	if is_skin_unlocked(id):
		return skins[id]["texture_path"]
	# Show locked asset if not unlocked
	match id:
		"ship_3":
			return "res://Textures/Player/ship_3_locked.png"
		"ship_4":
			return "res://Textures/Player/ship_4_locked.png"
		"ship_5":
			return "res://Textures/Player/ship_5_locked.png"
		_:
			return skins[id]["texture_path"]

func get_equipped_texture() -> Texture2D:
	if not skins.has(equipped):
		equipped = "ship_1"
	var path = get_skin_texture_path(equipped)
	return load(path)


func get_starting_weapon(skin_id: String = "") -> String:
	var id: String = skin_id if not skin_id.is_empty() else equipped
	if not skins.has(id):
		id = "ship_1"
	var data: Dictionary = skins[id]
	return data.get("starting_weapon", "pulselaser1")


func equip_skin(id: String) -> void:
	if not skins.has(id):
		push_warning("Tried to equip unknown skin id: %s" % id)
		return
	if not is_skin_unlocked(id):
		push_warning("Skin %s is locked. Complete its challenge to unlock." % id)
		return
	equipped = id
	save_data()
	print("SkinManager: equipped set to ", equipped)


func save_data() -> void:
	var cf := ConfigFile.new()
	cf.set_value("skins", "equipped", equipped)
	cf.save(SAVE_PATH)


func load_data() -> void:
	var cf := ConfigFile.new()
	var err := cf.load(SAVE_PATH)
	if err == OK:
		equipped = cf.get_value("skins", "equipped", equipped)
