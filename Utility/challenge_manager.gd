extends Node


var challenge_progress = {}
var completed_challenges = {}
var notification_callback = null

func _get_save_path() -> String:
	var profile_name = "default"
	if Engine.has_singleton("LocalProfile"):
		profile_name = Engine.get_singleton("LocalProfile").get_current_profile()
	elif has_node("/root/LocalProfile"):
		profile_name = get_node("/root/LocalProfile").get_current_profile()
	if profile_name.is_empty():
		profile_name = "default"
	return "user://profiles/%s_challenges.save" % profile_name


func initialize():
	load_progress()

func set_notification_callback(cb):
	notification_callback = cb

func load_progress():
	var file = FileAccess.open(_get_save_path(), FileAccess.READ)
	if file:
		var data = file.get_var()
		challenge_progress = data.get("progress", {})
		completed_challenges = data.get("completed", {})
		file.close()
	else:
		challenge_progress = {}
		completed_challenges = {}

func save_progress():
	var file = FileAccess.open(_get_save_path(), FileAccess.WRITE)
	if file:
		var data = {
			"progress": challenge_progress,
			"completed": completed_challenges
		}
		file.store_var(data)
		file.close()

func get_progress(challenge_id: String) -> int:
	return challenge_progress.get(challenge_id, 0)

func is_completed(challenge_id: String) -> bool:
	return completed_challenges.get(challenge_id, false)

func set_progress(challenge_id: String, value: int):
	challenge_progress[challenge_id] = value
	check_completion(challenge_id)
	save_progress()

func increment_progress(challenge_id: String, amount: int = 1):
	challenge_progress[challenge_id] = challenge_progress.get(challenge_id, 0) + amount
	check_completion(challenge_id)
	save_progress()

func check_completion(challenge_id: String):
	var challenge = get_node("/root/challenges_db").get_challenge_by_id(challenge_id)
	if not challenge:
		return
	if challenge_progress.get(challenge_id, 0) >= challenge["target"]:
		if not completed_challenges.get(challenge_id, false):
			completed_challenges[challenge_id] = true
			save_progress()
			if notification_callback:
				notification_callback.call(challenge["description"])

func get_completed_challenges():
	return completed_challenges.keys()

func reset_progress():
	challenge_progress = {}
	completed_challenges = {}
	save_progress()
