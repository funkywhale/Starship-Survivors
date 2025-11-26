extends Node2D

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var resume_button: Button = $PauseMenu/Panel/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $PauseMenu/Panel/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $PauseMenu/Panel/VBoxContainer/QuitButton
@onready var background_sprite: Sprite2D = $ParallaxBackground/ParallaxLayer/Sprite2D


func _ready() -> void:
	pause_menu.visible = false
	

	_set_random_background()
	
	TitleMusicPlayer.stop_title_music()

	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	var new_state := not get_tree().paused
	get_tree().paused = new_state
	pause_menu.visible = new_state


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()


func _set_random_background() -> void:
	var random_bg_num := randi_range(1, 7)
	var bg_path := "res://Textures/Backgrounds/space_%d.png" % random_bg_num
	var texture := load(bg_path) as Texture2D
	if texture:
		background_sprite.texture = texture
	else:
		push_error("Failed to load background: %s" % bg_path)
