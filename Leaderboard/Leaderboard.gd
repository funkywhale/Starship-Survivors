extends Control

@onready var entries_container = $MarginContainer/VBoxContainer/ScrollContainer/EntriesContainer
@onready var loading_label = $MarginContainer/VBoxContainer/LoadingLabel
@onready var back_button = $MarginContainer/VBoxContainer/BackButton

const LEADERBOARD_NAME = "survival_time"

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	_load_leaderboard()

func _load_leaderboard():
	loading_label.text = "Loading leaderboard..."
	loading_label.visible = true

	for child in entries_container.get_children():
		child.queue_free()

	# Get local leaderboard entries
	var entries = LocalProfile.get_leaderboard()

	loading_label.visible = false

	if entries.size() == 0:
		var no_entries_label = Label.new()
		no_entries_label.text = "No entries yet! Be the first to play!"
		no_entries_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		entries_container.add_child(no_entries_label)
		return

	# Display entries
	for i in range(entries.size()):
		var entry = entries[i]
		_create_entry_row(i + 1, entry)

func _create_entry_row(rank: int, entry):
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)

	# Rank
	var rank_label = Label.new()
	rank_label.text = str(rank)
	rank_label.custom_minimum_size = Vector2(40, 0)
	rank_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rank_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(rank_label)

	# Player name
	var name_label = Label.new()
	name_label.text = entry.get("profile_name", "Unknown")
	name_label.custom_minimum_size = Vector2(100, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(name_label)

	# Ship sprite
	var ship_id = entry.get("ship_id", "ship_1")
	var ship_sprite = TextureRect.new()
	ship_sprite.custom_minimum_size = Vector2(20, 16)
	ship_sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	ship_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Load ship texture
	var skin_manager = get_node_or_null("/root/SkinManager")
	if skin_manager and skin_manager.skins.has(ship_id):
		var texture_path = skin_manager.skins[ship_id]["texture_path"]
		var texture = load(texture_path) as Texture2D
		if texture:
			ship_sprite.texture = texture
			# Create AtlasTexture to show only first frame
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			var frame_width = int(texture.get_width() / 3.0) # hframes = 3
			var frame_height = texture.get_height()
			atlas.region = Rect2(0, 0, frame_width, frame_height)
			ship_sprite.texture = atlas
	hbox.add_child(ship_sprite)

	# Ship name
	var ship_name_label = Label.new()
	if skin_manager and skin_manager.skins.has(ship_id):
		ship_name_label.text = skin_manager.skins[ship_id]["name"]
	else:
		ship_name_label.text = "Unknown Ship"
	ship_name_label.custom_minimum_size = Vector2(120, 0)
	ship_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ship_name_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(ship_name_label)

	# Score (survival time)
	var score_label = Label.new()
	var time_survived = int(entry.get("time", 0))
	var minutes = int(time_survived / 60.0)
	var seconds = time_survived % 60
	score_label.text = "%02d:%02d" % [minutes, seconds]
	score_label.custom_minimum_size = Vector2(60, 0)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(score_label)

	# Enemies killed
	var kills_label = Label.new()
	kills_label.text = str(entry.get("kills", 0))
	kills_label.custom_minimum_size = Vector2(60, 0)
	kills_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kills_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	kills_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(kills_label)

	entries_container.add_child(hbox)

func _on_back_button_pressed():
	var parent = get_parent()
	if parent and parent.has_method("_close_leaderboard"):
		parent._close_leaderboard()
	else:
		get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
