extends Control

@onready var preview_texture: TextureRect = $MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Preview
@onready var skin_name_label: Label = $MarginContainer/VBoxContainer/SkinName

@onready var weapon_icon: TextureRect = $"%WeaponIcon"
@onready var weapon_name: Label = $"%WeaponName"

@onready var left_arrow: Button = $MarginContainer/VBoxContainer/Selector/leftArrow
@onready var right_arrow: Button = $MarginContainer/VBoxContainer/Selector/rightArrow

@onready var select_button: Button = $MarginContainer/VBoxContainer/actionButtons/Select
@onready var back_button: Button = $BackButton

@onready var skin_manager := get_node("/root/SkinManager")

var skin_ids: Array = []
var current_index: int = 0


func _ready() -> void:
	skin_ids = skin_manager.skins.keys()

	# start on currently equipped skin 
	var equipped_id: String = skin_manager.equipped
	var idx := skin_ids.find(equipped_id)
	current_index = 0 if idx == -1 else idx

	# UI signals
	left_arrow.pressed.connect(_on_left_pressed)
	right_arrow.pressed.connect(_on_right_pressed)
	select_button.pressed.connect(_on_select_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# preview texture
	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_texture.custom_minimum_size = Vector2(96, 96)
	
	# weapon display
	weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	weapon_icon.custom_minimum_size = Vector2(64, 64)

	_update_ui()


func _update_ui() -> void:
	if skin_ids.is_empty():
		return
	var skin_id: String = skin_ids[current_index]
	var data: Dictionary = skin_manager.skins[skin_id]
	var is_unlocked = skin_manager.is_skin_unlocked(skin_id)
	var tex_path = skin_manager.get_skin_texture_path(skin_id)
	var tex: Texture2D = load(tex_path)
	if is_unlocked:
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		var hframes: int = int(data.get("hframes", 2))
		var frame_width: int = int(float(tex.get_width()) / float(hframes))
		atlas.region = Rect2(0, 0, frame_width, tex.get_height())
		preview_texture.texture = atlas
	else:
		# Locked icon is a single sprite, not a sheet
		preview_texture.texture = tex
	var base_name: String = data["name"]
	skin_name_label.text = base_name

	# Update weapon display
	var weapon_id: String = skin_manager.get_starting_weapon(skin_id)
	var weapon_data: Dictionary = UpgradeDb.get_upgrade_data(weapon_id)
	if not is_unlocked:
		# Show locked weapon icon
		match skin_id:
			"ship_3":
				weapon_icon.texture = load("res://Textures/Items/Weapons/plasma_icon_locked.png")
				weapon_name.text = "Locked"
			"ship_4":
				weapon_icon.texture = load("res://Textures/Items/Weapons/scattershot_icon_locked.png")
				weapon_name.text = "Locked"
			"ship_5":
				weapon_icon.texture = load("res://Textures/Items/Weapons/ion_laser_locked.png")
				weapon_name.text = "Locked"
			_:
				weapon_icon.texture = null
				weapon_name.text = "Locked"
		select_button.disabled = true
		select_button.text = "Locked"
	else:
		if not weapon_data.is_empty():
			var weapon_texture: Texture2D = load(weapon_data["icon"])
			weapon_icon.texture = weapon_texture
			weapon_name.text = weapon_data["displayname"]
		select_button.disabled = false
		select_button.text = "Start"


func _on_left_pressed() -> void:
	if skin_ids.is_empty():
		return
	current_index = (current_index - 1 + skin_ids.size()) % skin_ids.size()
	_update_ui()


func _on_right_pressed() -> void:
	if skin_ids.is_empty():
		return
	current_index = (current_index + 1) % skin_ids.size()
	_update_ui()


func _on_select_pressed() -> void:
	if skin_ids.is_empty():
		return
	var skin_id: String = skin_ids[current_index]
	if not skin_manager.is_skin_unlocked(skin_id):
		return # Do nothing if locked
	# Equip selected skin then start the game world
	skin_manager.equip_skin(skin_id)
	get_tree().change_scene_to_file("res://World/world.tscn")


func _on_back_pressed() -> void:
	# If embedded in menu, ask parent to close; else fallback to scene change.
	var parent = get_parent()
	if parent and parent.has_method("_close_skins_menu"):
		parent._close_skins_menu()
	else:
		get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
