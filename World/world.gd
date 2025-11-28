extends Node2D

@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var resume_button: Button = $PauseMenu/Panel/VBoxContainer/ResumeButton
@onready var main_menu_button: Button = $PauseMenu/Panel/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $PauseMenu/Panel/VBoxContainer/QuitButton
@onready var background_sprite: Sprite2D = $ParallaxBackground/ParallaxLayer/Sprite2D


func _ready() -> void:
	pause_menu.visible = false

	# Ensure Pause audio controls are hidden initially (in case of editor changes)
	if has_node("PauseMenu/PauseAudioControls"):
		var pac := get_node("PauseMenu/PauseAudioControls")
		pac.visible = false

	
	_set_random_background()
	
	TitleMusicPlayer.stop_title_music()

	resume_button.click_end.connect(_on_resume_pressed)
	main_menu_button.click_end.connect(_on_main_menu_pressed)
	quit_button.click_end.connect(_on_quit_pressed)

	# Wire pause audio sliders safely (use get_node_or_null so missing nodes don't crash)
	var settings := get_node_or_null("/root/Settings")
	var master_node := get_node_or_null("PauseMenu/PauseAudioControls/PauseAudioControls#MasterSlider")
	if master_node:
		var init_master := 1.0
		if settings:
			init_master = settings.get_master_volume()
		else:
			var midx := AudioServer.get_bus_index("Master")
			if midx >= 0:
				var mdb := AudioServer.get_bus_volume_db(midx)
				init_master = 0.0 if mdb <= -80.0 else clamp((mdb + 80.0) / 80.0, 0.0, 1.0)
		master_node.value = init_master
		master_node.connect("value_changed", Callable(self, "_on_pause_master_changed"))
	var music_node := get_node_or_null("PauseMenu/PauseAudioControls/PauseAudioControls#MusicSlider")
	if music_node:
		var init_music := 1.0
		if settings:
			init_music = settings.get_music_volume()
		else:
			var midx2 := AudioServer.get_bus_index("Music")
			if midx2 >= 0:
				var mdb2 := AudioServer.get_bus_volume_db(midx2)
				init_music = 0.0 if mdb2 <= -80.0 else clamp((mdb2 + 80.0) / 80.0, 0.0, 1.0)
		music_node.value = init_music
		music_node.connect("value_changed", Callable(self, "_on_pause_music_changed"))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()


func _toggle_pause() -> void:
	var new_state := not get_tree().paused
	get_tree().paused = new_state
	pause_menu.visible = new_state
	# Toggle PauseAudioControls visibility explicitly as well
	if has_node("PauseMenu/PauseAudioControls"):
		$PauseMenu/PauseAudioControls.visible = new_state
		if new_state:
			_sync_pause_audio_sliders()
func _sync_pause_audio_sliders() -> void:
	var settings := get_node_or_null("/root/Settings")
	var master_node := get_node_or_null("PauseMenu/PauseAudioControls/PauseAudioControls#MasterSlider")
	if master_node and settings:
		master_node.value = settings.get_master_volume()
	var music_node := get_node_or_null("PauseMenu/PauseAudioControls/PauseAudioControls#MusicSlider")
	if music_node and settings:
		music_node.value = settings.get_music_volume()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	if has_node("PauseMenu/PauseAudioControls"):
		$PauseMenu/PauseAudioControls.visible = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	pause_menu.visible = false
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
	if has_node("PauseMenu/PauseAudioControls"):
		$PauseMenu/PauseAudioControls.visible = false

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
	if has_node("PauseMenu/PauseAudioControls"):
		$PauseMenu/PauseAudioControls.visible = false

func _on_pause_master_changed(val: float) -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.set_master_volume(val)
	var idx := AudioServer.get_bus_index("Master")
	if idx >= 0:
		var db: float = -80.0 if val <= 0.0001 else lerp(-80.0, 0.0, clamp(val, 0.0, 1.0))
		AudioServer.set_bus_volume_db(idx, db)

func _on_pause_music_changed(val: float) -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.set_music_volume(val)
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		var db: float = -80.0 if val <= 0.0001 else lerp(-80.0, 0.0, clamp(val, 0.0, 1.0))
		AudioServer.set_bus_volume_db(idx, db)


func _set_random_background() -> void:
	var random_bg_num := randi_range(1, 6)
	var bg_path := "res://Textures/Backgrounds/space_%d.png" % random_bg_num
	var texture := load(bg_path) as Texture2D
	if texture:
		background_sprite.texture = texture
	else:
		push_error("Failed to load background: %s" % bg_path)

# Time / kill counter update driver
var _elapsed_time: float = 0.0
var _last_whole_second: int = 0

func _process(delta: float) -> void:
	_elapsed_time += delta
	var whole := int(floor(_elapsed_time))
	if whole != _last_whole_second:
		_last_whole_second = whole
		var player := get_tree().get_first_node_in_group("player")
		if player and player.has_method("change_time"):
			player.change_time(whole)
