extends Node

const SAVE_PATH := "user://skins.save"

# all available skins
var skins := {
	"ship_1": {
		"name": "Starfighter Mk I",
		#"price": 0,
		"texture_path": "res://Textures/Player/player_sprite2.png"
	},
	"ship_2": {
		"name": "Starfighter Mk II",
		#"price": 0,
		"texture_path": "res://Textures/Player/player_sprite.png"
	},
	"ship_3": {
		"name": "Skyfeather",
		#"price": 0,
		"texture_path": "res://Textures/Player/player_sprite3.png"
	},
	"ship_4": {
		"name": "Lightning Craft",
		#"price": 0,
		"texture_path": "res://Textures/Player/player_sprite4.png"
	},
	"ship_5": {
		"name": "Cosmic Serpent",
		#"price": 0,
		"texture_path": "res://Textures/Player/player_sprite5.png"
	},
}

# currently equipped skin ID
var equipped: String = "ship_1"


func _ready() -> void:
	load_data()


func get_equipped_texture() -> Texture2D:
	if not skins.has(equipped):
		equipped = "ship_1"
	var data: Dictionary = skins[equipped]
	return load(data["texture_path"])


func equip_skin(id: String) -> void:
	if not skins.has(id):
		push_warning("Tried to equip unknown skin id: %s" % id)
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
