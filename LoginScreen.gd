extends Control

@onready var profile_name_input = $VBoxContainer/ProfileNameInput
@onready var continue_button = $VBoxContainer/ContinueButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var skip_button = $SkipButton

func _ready():
	continue_button.pressed.connect(_on_ContinueButton_pressed)
	skip_button.pressed.connect(_on_SkipButton_pressed)

	# Always reset input and label when entering
	profile_name_input.text = ""
	status_label.text = "Enter a profile name to begin."

	# Only auto-login if not forcing new profile
	var force_new = false
	if Engine.has_singleton("LocalProfile"):
		force_new = Engine.get_singleton("LocalProfile").force_new_profile
		Engine.get_singleton("LocalProfile").force_new_profile = false
	elif has_node("/root/LocalProfile"):
		force_new = get_node("/root/LocalProfile").force_new_profile
		get_node("/root/LocalProfile").force_new_profile = false

	# Auto-login to last played profile if it exists and is valid
	var last_profile = LocalProfile.get_current_profile()
	if not force_new and not last_profile.is_empty() and last_profile.length() >= 3:
		profile_name_input.text = last_profile
		status_label.text = "Auto-signing in as %s..." % last_profile
		_set_profile_name(true)


func _on_ContinueButton_pressed():
	$VBoxContainer/ContinueButton/snd_click.play()
	_set_profile_name()
	$VBoxContainer/ContinueButton/snd_click.connect("finished", Callable(self, "_on_continue_click_sound_finished"), Object.CONNECT_ONE_SHOT)

func _on_SkipButton_pressed():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")


func _set_profile_name(auto_login = false):
	var profile_name = profile_name_input.text.strip_edges()
	if not auto_login:
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
	if LocalProfile.set_profile(profile_name):
		# Save last played profile for auto-login
		if Engine.has_singleton("Settings"):
			Engine.get_singleton("Settings").set_last_played_profile(profile_name)
		elif has_node("/root/Settings"):
			get_node("/root/Settings").set_last_played_profile(profile_name)
		status_label.text = "Profile set!"
		if Engine.has_singleton("challenge_manager"):
			Engine.get_singleton("challenge_manager").initialize()
		elif has_node("/root/challenge_manager"):
			get_node("/root/challenge_manager").initialize()
		# If auto-login, skip sound and go straight to menu
		if auto_login:
			get_tree().call_deferred("change_scene_to_file", "res://TitleScreen/menu.tscn")
	else:
		status_label.text = "Failed to set profile."


func _on_continue_click_sound_finished():
	get_tree().call_deferred("change_scene_to_file", "res://TitleScreen/menu.tscn")
