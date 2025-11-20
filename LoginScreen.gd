extends Control

@onready var email_input = $CenterContainer/VBoxContainer/EmailInput
@onready var password_input = $CenterContainer/VBoxContainer/PasswordInput
@onready var status_label = $CenterContainer/VBoxContainer/StatusLabel
@onready var login_button = $CenterContainer/VBoxContainer/LoginButton
@onready var register_button = $CenterContainer/VBoxContainer/RegisterButton
@onready var skip_button = $SkipButton

func _ready():
	login_button.pressed.connect(_on_LoginButton_pressed)
	register_button.pressed.connect(_on_RegisterButton_pressed)
	skip_button.pressed.connect(_on_SkipButton_pressed)


# This is the handler for the login button
func _on_LoginButton_pressed():
	_perform_login()

# This is the handler for the register button
func _on_RegisterButton_pressed():
	_perform_registration()

func _on_SkipButton_pressed():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")


# --- ASYNC LOGIC (The official, documented method) ---

func _perform_login():
	var email = email_input.text
	var password = password_input.text
	if email.is_empty() or password.is_empty():
		status_label.text = "Please enter an email and password."
		return

	status_label.text = "Logging in..."

	var res = await Talo.player_auth.login(email, password)

	match res:
		Talo.player_auth.LoginResult.OK:
			status_label.text = "Login successful!"
			get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

		Talo.player_auth.LoginResult.VERIFICATION_REQUIRED:
			status_label.text = "Please verify your email."

		Talo.player_auth.LoginResult.FAILED:
			match Talo.player_auth.last_error.get_code():
				TaloAuthError.ErrorCode.INVALID_CREDENTIALS:
					status_label.text = "Email or password is incorrect."
				_:
					status_label.text = Talo.player_auth.last_error.get_string()


func _perform_registration():
	var email = email_input.text
	var password = password_input.text
	if email.is_empty() or password.is_empty():
		status_label.text = "Please enter an email and password."
		return

	status_label.text = "Registering..."

	# Register with email as identifier, password, email for verification, and enable verification
	var res = await Talo.player_auth.register(email, password, email, false)

	if res == OK:
		status_label.text = "Registration successful!"
		get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
	else:
		match Talo.player_auth.last_error.get_code():
			TaloAuthError.ErrorCode.IDENTIFIER_TAKEN:
				status_label.text = "That email is already taken."
			_:
				status_label.text = Talo.player_auth.last_error.get_string()
