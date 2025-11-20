extends Node2D   

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var resume_button: Button = $PauseMenu/Panel/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $PauseMenu/Panel/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $PauseMenu/Panel/VBoxContainer/QuitButton


func _ready() -> void:
	pause_menu.visible = false

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
