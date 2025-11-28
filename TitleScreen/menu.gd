extends Control

# Embedded menu panels
var skins_menu_instance: Control = null
var leaderboard_instance: Control = null

# Scenes
var skins_menu_scene: PackedScene = preload("res://SkinsMenu/skins_menu.tscn")
var leaderboard_scene: PackedScene = preload("res://Leaderboard/Leaderboard.tscn")

func _ready() -> void:
	# Restart title music when returning to menu
	TitleMusicPlayer.start_title_music()
	
	if has_node("ProfileLabel"):
		var profile_name = ""
		if Engine.has_singleton("LocalProfile"):
			profile_name = Engine.get_singleton("LocalProfile").get_current_profile()
		elif has_node("/root/LocalProfile"):
			profile_name = get_node("/root/LocalProfile").get_current_profile()
		$ProfileLabel.text = "Profile: " + profile_name

	# Wire audio sliders if present
	# Connect sliders regardless of Settings autoload so they always control audio
	if has_node("AudioControls"):
		if has_node("AudioControls/MasterSlider"):
			var mval := 1.0
			var settings := get_node_or_null("/root/Settings")
			if settings:
				mval = settings.get_master_volume()
			else:
				var midx := AudioServer.get_bus_index("Master")
				if midx >= 0:
					var mdb := AudioServer.get_bus_volume_db(midx)
					mval = 0.0 if mdb <= -80.0 else clamp((mdb + 80.0) / 80.0, 0.0, 1.0)
			$AudioControls/MasterSlider.value = mval
			$AudioControls/MasterSlider.connect("value_changed", Callable(self, "_on_master_changed"))
		if has_node("AudioControls/MusicSlider"):
			var muval := 1.0
			var settings2 := get_node_or_null("/root/Settings")
			if settings2:
				muval = settings2.get_music_volume()
			else:
				var midx2 := AudioServer.get_bus_index("Music")
				if midx2 >= 0:
					var mdb2 := AudioServer.get_bus_volume_db(midx2)
					muval = 0.0 if mdb2 <= -80.0 else clamp((mdb2 + 80.0) / 80.0, 0.0, 1.0)
			$AudioControls/MusicSlider.value = muval
			$AudioControls/MusicSlider.connect("value_changed", Callable(self, "_on_music_changed"))

func _on_btn_play_click_end() -> void:
	_open_skins_menu()

# --- Skins Menu ---
func _open_skins_menu() -> void:
	if skins_menu_instance: return
	_set_menu_visible(false)
	skins_menu_instance = skins_menu_scene.instantiate()
	add_child(skins_menu_instance)

func _close_skins_menu() -> void:
	if not skins_menu_instance: return
	skins_menu_instance.queue_free()
	skins_menu_instance = null
	_set_menu_visible(true)

# --- Leaderboard ---
func _open_leaderboard() -> void:
	if leaderboard_instance: return
	_set_menu_visible(false)
	leaderboard_instance = leaderboard_scene.instantiate()
	add_child(leaderboard_instance)

func _close_leaderboard() -> void:
	if not leaderboard_instance: return
	leaderboard_instance.queue_free()
	leaderboard_instance = null
	_set_menu_visible(true)

func _set_menu_visible(menu_visible: bool) -> void:
	if has_node("btn_play"): $btn_play.visible = menu_visible
	if has_node("btn_leaderboard"): $btn_leaderboard.visible = menu_visible
	if has_node("btn_exit"): $btn_exit.visible = menu_visible
	if has_node("btn_skins"): $btn_skins.visible = menu_visible
	if has_node("TextureRect"): $TextureRect.visible = menu_visible

# Removed unused fade callback and animation usage.

func _on_btn_leaderboard_click_end() -> void:
	_open_leaderboard()

func _on_btn_exit_click_end() -> void:
	get_tree().quit()

func _on_btn_skins_click_end() -> void:
	_open_skins_menu()

func _on_master_changed(val: float) -> void:
	# Update Settings if present, and always apply to AudioServer immediately
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.set_master_volume(val)
	var idx := AudioServer.get_bus_index("Master")
	if idx >= 0:
		var db: float = -80.0 if val <= 0.0001 else lerp(-80.0, 0.0, clamp(val, 0.0, 1.0))
		AudioServer.set_bus_volume_db(idx, db)

func _on_music_changed(val: float) -> void:
	# Update Settings if present, and always apply to AudioServer immediately
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.set_music_volume(val)
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		var db: float = -80.0 if val <= 0.0001 else lerp(-80.0, 0.0, clamp(val, 0.0, 1.0))
		AudioServer.set_bus_volume_db(idx, db)
