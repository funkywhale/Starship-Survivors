extends Control


func _ready():
	$MarginContainer/VBoxContainer/BackButton.connect("pressed", Callable(self, "_on_BackButton_pressed"))
	var entries_container = $MarginContainer/VBoxContainer/ScrollContainer/EntriesContainer
	# Remove all children from EntriesContainer
	for child in entries_container.get_children():
		entries_container.remove_child(child)
		child.queue_free()
	var challenges = get_node("/root/challenges_db").get_challenges()
	var cm = get_node("/root/challenge_manager")
	for i in range(challenges.size()):
		var c = challenges[i]
		var completed = cm.is_completed(c["id"])
		var row = HBoxContainer.new()

		var num_label = Label.new()
		num_label.text = str(i + 1)
		num_label.custom_minimum_size = Vector2(40, 0)
		row.add_child(num_label)

		var desc_label = Label.new()
		desc_label.text = c["description"]
		desc_label.custom_minimum_size = Vector2(400, 0)
		row.add_child(desc_label)

		var completed_label = Label.new()
		completed_label.text = "1/1" if completed else "0/1"
		completed_label.custom_minimum_size = Vector2(100, 0)
		completed_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		completed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		completed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if not completed:
			completed_label.add_theme_color_override("font_color", Color(1, 1, 1))
		row.add_child(completed_label)

		entries_container.add_child(row)


func _on_BackButton_pressed():
	var parent = get_parent()
	if parent and parent.has_method("_close_challenges_screen"):
		parent._close_challenges_screen()
	else:
		get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
