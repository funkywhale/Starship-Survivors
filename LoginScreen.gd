extends Control

@onready var profile_name_input = $VBoxContainer/ProfileNameInput
@onready var continue_button = $VBoxContainer/ContinueButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var skip_button = $SkipButton

func _ready():
	continue_button.pressed.connect(_on_ContinueButton_pressed)
	skip_button.pressed.connect(_on_SkipButton_pressed)
	
	# Auto-fill profile name if one exists
	var existing_profile = LocalProfile.get_current_profile()
	if not existing_profile.is_empty():
		profile_name_input.text = existing_profile


func _on_ContinueButton_pressed():
	$VBoxContainer/ContinueButton/snd_click.play()
	_set_profile_name()
	$VBoxContainer/ContinueButton/snd_click.connect("finished", Callable(self, "_on_continue_click_sound_finished"), Object.CONNECT_ONE_SHOT)

func _on_SkipButton_pressed():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")


func _set_profile_name():
	var profile_name = profile_name_input.text.strip_edges()
	
	if profile_name.is_empty():
		status_label.text = "Please enter a profile name."
		return
	
	if profile_name.length() < 3:
		status_label.text = "Profile name must be at least 3 characters."
		return
	
	if profile_name.length() > 20:
		status_label.text = "Profile name must be 20 characters or less."
		return

	status_label.text = "Setting profile name..."
	
	# Use local profile system
	if LocalProfile.set_profile(profile_name):
		status_label.text = "Profile set!"
		# Scene change now handled by sound finished signal
	else:
		status_label.text = "Failed to set profile."


func _on_continue_click_sound_finished():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
