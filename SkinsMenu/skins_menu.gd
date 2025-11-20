extends Control

@onready var preview_texture: TextureRect = $MarginContainer/VBoxContainer/CenterContainer/Preview
@onready var skin_name_label: Label = $MarginContainer/VBoxContainer/SkinName

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

	_update_ui()


func _update_ui() -> void:
	if skin_ids.is_empty():
		return

	var skin_id: String = skin_ids[current_index]
	var data: Dictionary = skin_manager.skins[skin_id]

	# load texture for preview
	var tex: Texture2D = load(data["texture_path"])
	preview_texture.texture = tex

	# show name + equipped tag
	var base_name: String = data["name"]
	if skin_id == skin_manager.equipped:
		skin_name_label.text = "%s (Equipped)" % base_name
		select_button.disabled = true
		select_button.text = "Equipped"
	else:
		skin_name_label.text = base_name
		select_button.disabled = false
		select_button.text = "Equip"


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
	skin_manager.equip_skin(skin_id)
	_update_ui()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
