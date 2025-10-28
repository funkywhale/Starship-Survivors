extends Control

@onready var entries_container = $MarginContainer/VBoxContainer/ScrollContainer/EntriesContainer
@onready var loading_label = $MarginContainer/VBoxContainer/LoadingLabel
@onready var back_button = $MarginContainer/VBoxContainer/BackButton

const LEADERBOARD_NAME = "survival_time"  # Change this to match your Talo leaderboard internal name

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	_load_leaderboard()

func _load_leaderboard():
	loading_label.text = "Loading leaderboard..."
	loading_label.visible = true

	# Clear existing entries
	for child in entries_container.get_children():
		child.queue_free()

	# Fetch leaderboard entries
	var options = Talo.leaderboards.GetEntriesOptions.new()
	options.page = 0

	var res = await Talo.leaderboards.get_entries(LEADERBOARD_NAME, options)

	if not is_instance_valid(res):
		loading_label.text = "Failed to load leaderboard. Make sure '%s' exists in Talo dashboard." % LEADERBOARD_NAME
		return

	loading_label.visible = false

	var entries = res.entries

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
	rank_label.custom_minimum_size = Vector2(30, 0)
	rank_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(rank_label)

	# Player name
	var name_label = Label.new()
	name_label.text = entry.player_alias.identifier
	name_label.custom_minimum_size = Vector2(150, 0)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(name_label)

	# Score (survival time)
	var score_label = Label.new()
	var time_survived = int(entry.score)
	var minutes = int(time_survived / 60.0)
	var seconds = time_survived % 60
	score_label.text = "%02d:%02d" % [minutes, seconds]
	score_label.custom_minimum_size = Vector2(60, 0)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.add_theme_font_size_override("font_size", 10)
	hbox.add_child(score_label)

	# Level is tracked internally but not displayed

	entries_container.add_child(hbox)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
