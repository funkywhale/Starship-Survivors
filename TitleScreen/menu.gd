extends Control

var level: String = "res://World/world.tscn"

func _on_btn_play_click_end() -> void:
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("fade_out")
	else:
		get_tree().change_scene_to_file(level)

func _on_fade_out_finished() -> void:
	get_tree().change_scene_to_file(level)

func _on_btn_leaderboard_click_end() -> void:
	get_tree().change_scene_to_file("res://Leaderboard/Leaderboard.tscn")

func _on_btn_exit_click_end() -> void:
	get_tree().quit()


func _on_btn_skins_click_end() -> void:
	get_tree().change_scene_to_file("res://SkinsMenu/skins_menu.tscn")
