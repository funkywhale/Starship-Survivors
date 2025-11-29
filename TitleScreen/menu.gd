extends Control


# Embedded menu panels
var skins_menu_instance: Control = null
var leaderboard_instance: Control = null
var challenges_instance: Control = null

# Scenes
var challenges_scene: PackedScene = preload("res://GUI/challenges_screen.tscn")
var skins_menu_scene: PackedScene = preload("res://SkinsMenu/skins_menu.tscn")
var leaderboard_scene: PackedScene = preload("res://Leaderboard/Leaderboard.tscn")

func _update_profile_label():
	var current_profile = ""
	if Engine.has_singleton("LocalProfile"):
		current_profile = Engine.get_singleton("LocalProfile").get_current_profile()
	elif has_node("/root/LocalProfile"):
		current_profile = get_node("/root/LocalProfile").get_current_profile()
	if has_node("ProfileLabel"):
		if current_profile != "" and current_profile.length() >= 3:
			$ProfileLabel.text = "Profile: " + current_profile
		else:
			$ProfileLabel.text = "Profile: (none)"

func _ready() -> void:
	# Connect audio slider signals once
	if has_node("AudioControls"):
		if has_node("AudioControls/MasterSlider"):
			$AudioControls/MasterSlider.connect("value_changed", Callable(self, "_on_master_changed"))
		if has_node("AudioControls/MusicSlider"):
			$AudioControls/MusicSlider.connect("value_changed", Callable(self, "_on_music_changed"))
	if has_node("btn_create_profile"):
		$btn_create_profile.connect("pressed", Callable(self, "_on_btn_create_profile_pressed"))
	if has_node("btn_switch_profile"):
		$btn_switch_profile.connect("pressed", Callable(self, "_on_btn_switch_profile_pressed"))
	if has_node("btn_play"):
		$btn_play.connect("pressed", Callable(self, "_on_btn_play_pressed"))
	if has_node("btn_challenges"):
		$btn_challenges.connect("pressed", Callable(self, "_on_btn_challenges_pressed"))
	if has_node("btn_leaderboard"):
		$btn_leaderboard.connect("pressed", Callable(self, "_on_btn_leaderboard_pressed"))
	if has_node("btn_exit"):
		$btn_exit.connect("pressed", Callable(self, "_on_btn_exit_pressed"))
	if has_node("btn_skins"):
		$btn_skins.connect("pressed", Callable(self, "_on_btn_skins_pressed"))
	if has_node("btn_debug_unlock_challenges"):
		$btn_debug_unlock_challenges.connect("pressed", Callable(self, "_on_btn_debug_unlock_challenges_pressed"))
		$btn_debug_unlock_challenges.visible = OS.is_debug_build()
	if has_node("ProfilePopup") and $ProfilePopup.has_node("ProfileList"):
		$ProfilePopup/ProfileList.connect("item_selected", Callable(self, "_on_profile_selected"))
	_update_profile_label()

func _on_btn_create_profile_pressed() -> void:
	if Engine.has_singleton("LocalProfile"):
		Engine.get_singleton("LocalProfile").force_new_profile = true
	elif has_node("/root/LocalProfile"):
		get_node("/root/LocalProfile").force_new_profile = true
	get_tree().change_scene_to_file("res://LoginScreen.tscn")

func _on_btn_switch_profile_pressed() -> void:
	var profile_list = $ProfilePopup/ProfileList
	profile_list.clear()
	var profiles = []
	if Engine.has_singleton("LocalProfile"):
		profiles = Engine.get_singleton("LocalProfile").profiles.keys()
	elif has_node("/root/LocalProfile"):
		profiles = get_node("/root/LocalProfile").profiles.keys()
	for p in profiles:
		profile_list.add_item(p)
	$ProfilePopup.visible = true
	$ProfilePopup.popup_centered()

func _on_profile_selected(index: int) -> void:
	var profile_list = $ProfilePopup/ProfileList
	var selected_profile = profile_list.get_item_text(index)
	if Engine.has_singleton("LocalProfile"):
		Engine.get_singleton("LocalProfile").set_profile(selected_profile)
	elif has_node("/root/LocalProfile"):
		get_node("/root/LocalProfile").set_profile(selected_profile)
	if Engine.has_singleton("challenge_manager"):
		Engine.get_singleton("challenge_manager").initialize()
	elif has_node("/root/challenge_manager"):
		get_node("/root/challenge_manager").initialize()
	# Always reload skin data after profile switch
	if Engine.has_singleton("SkinManager"):
		Engine.get_singleton("SkinManager").load_data()
	elif has_node("/root/SkinManager"):
		get_node("/root/SkinManager").load_data()
	_update_profile_label()
	$ProfilePopup.visible = false
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

func _on_btn_challenges_pressed() -> void:
	_open_challenges_screen()

func _open_challenges_screen() -> void:
	if challenges_instance: return
	_set_menu_visible(false)
	challenges_instance = challenges_scene.instantiate()
	add_child(challenges_instance)

func _close_challenges_screen() -> void:
	if not challenges_instance: return
	challenges_instance.queue_free()
	challenges_instance = null
	_set_menu_visible(true)

func _on_btn_play_pressed() -> void:
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
	if has_node("btn_challenges"): $btn_challenges.visible = menu_visible
	if has_node("btn_leaderboard"): $btn_leaderboard.visible = menu_visible
	if has_node("btn_exit"): $btn_exit.visible = menu_visible
	if has_node("btn_leaderboard"): $btn_leaderboard.visible = menu_visible
	if has_node("btn_exit"): $btn_exit.visible = menu_visible
	if has_node("btn_skins"): $btn_skins.visible = menu_visible
	if has_node("TextureRect"): $TextureRect.visible = menu_visible


func _on_btn_leaderboard_pressed() -> void:
	_open_leaderboard()

func _on_btn_exit_pressed() -> void:
	get_tree().quit()

func _on_btn_skins_pressed() -> void:
	_open_skins_menu()

# Debug: Unlock all challenges for current profile
func _on_btn_debug_unlock_challenges_pressed() -> void:
	var challenge_manager = null
	if Engine.has_singleton("challenge_manager"):
		challenge_manager = Engine.get_singleton("challenge_manager")
	elif has_node("/root/challenge_manager"):
		challenge_manager = get_node("/root/challenge_manager")
	var local_profile = null
	if Engine.has_singleton("LocalProfile"):
		local_profile = Engine.get_singleton("LocalProfile")
	elif has_node("/root/LocalProfile"):
		local_profile = get_node("/root/LocalProfile")
	if challenge_manager:
		var challenges_db = get_node("/root/challenges_db")
		var all_challenges = challenges_db.get_challenges()
		for c in all_challenges:
			challenge_manager.set_progress(c["id"], c["target"])
			if local_profile:
				local_profile.set_completed_challenge(c["id"])
		challenge_manager.save_progress()
		if local_profile:
			local_profile._save_data()
		# Optionally show notification
		if has_node("challenge_notification"):
			get_node("challenge_notification").show_notification("All challenges unlocked!")

func _on_master_changed(val: float) -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.set_master_volume(val)
	var idx := AudioServer.get_bus_index("Master")
	if idx >= 0:
		var db: float = -80.0 if val <= 0.0001 else lerp(-80.0, 0.0, clamp(val, 0.0, 1.0))
		AudioServer.set_bus_volume_db(idx, db)

func _on_music_changed(val: float) -> void:
	var settings := get_node_or_null("/root/Settings")
	if settings:
		settings.set_music_volume(val)
	var idx := AudioServer.get_bus_index("Music")
	if idx >= 0:
		var db: float = -80.0 if val <= 0.0001 else lerp(-80.0, 0.0, clamp(val, 0.0, 1.0))
		AudioServer.set_bus_volume_db(idx, db)
