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
