extends Node

# Local profile and leaderboard manager - no online functionality

const SAVE_PATH = "user://profile_data.save"
const MAX_LEADERBOARD_ENTRIES = 50

var current_profile_name: String = ""
var leaderboard_entries: Array = []

func _ready() -> void:
	_load_data()

# Profile Management
func set_profile(profile_name: String) -> bool:
	if profile_name.is_empty():
		return false
	
	current_profile_name = profile_name
	_save_data()
	return true

func get_current_profile() -> String:
	return current_profile_name

func has_profile() -> bool:
	return not current_profile_name.is_empty()

# Leaderboard Management
func submit_score(profile_name: String, time: int, level: int) -> void:
	# Create new entry
	var entry = {
		"profile_name": profile_name,
		"time": time,
		"level": level,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Check if this profile already has an entry
	var existing_index = -1
	for i in range(leaderboard_entries.size()):
		if leaderboard_entries[i]["profile_name"] == profile_name:
			existing_index = i
			break
	
	# Only update if this is a better score (longer survival time)
	if existing_index >= 0:
		if time > leaderboard_entries[existing_index]["time"]:
			leaderboard_entries[existing_index] = entry
			print("New personal best! Time: %d seconds" % time)
		else:
			print("Score submitted: Time: %d seconds (not a personal best)" % time)
	else:
		leaderboard_entries.append(entry)
		print("First score recorded! Time: %d seconds" % time)
	
	# Sort by time (descending - highest time first)
	leaderboard_entries.sort_custom(func(a, b): return a["time"] > b["time"])
	
	# Keep only top entries
	if leaderboard_entries.size() > MAX_LEADERBOARD_ENTRIES:
		leaderboard_entries.resize(MAX_LEADERBOARD_ENTRIES)
	
	_save_data()

func get_leaderboard() -> Array:
	return leaderboard_entries.duplicate()

func clear_leaderboard() -> void:
	leaderboard_entries.clear()
	_save_data()

# Save/Load
func _save_data() -> void:
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not save_file:
		push_error("Failed to open save file for writing")
		return
	
	var data = {
		"current_profile": current_profile_name,
		"leaderboard": leaderboard_entries
	}
	
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)
	save_file.close()

func _load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var save_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not save_file:
		push_error("Failed to open save file for reading")
		return
	
	var json_string = save_file.get_line()
	save_file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save data")
		return
	
	var data = json.data
	if typeof(data) == TYPE_DICTIONARY:
		current_profile_name = data.get("current_profile", "")
		leaderboard_entries = data.get("leaderboard", [])
