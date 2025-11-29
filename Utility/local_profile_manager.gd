# Move extends Node to the very top
extends Node

func clear_completed_challenges(profile_name: String = "") -> void:
	var profile_key = profile_name if not profile_name.is_empty() else current_profile_name
	if not profiles.has(profile_key):
		return
	profiles[profile_key]["completed_challenges"] = {}
	_save_data()
# Add a flag to force new profile creation
var force_new_profile: bool = false

# Local profile and leaderboard manager - no online functionality

const SAVE_PATH = "user://profile_data.save"
const MAX_LEADERBOARD_ENTRIES = 50

var current_profile_name: String = ""
var leaderboard_entries: Array = []
# Per-profile challenge and unlock data
var profiles: Dictionary = {}

func _ready() -> void:
	_load_data()

# Profile Management
func set_profile(profile_name: String) -> bool:
	if profile_name.is_empty():
		return false
	current_profile_name = profile_name
	# Initialize new profile with default locked state if not present
	if not profiles.has(profile_name):
		profiles[profile_name] = {
			"completed_challenges": {},
			"unlocked_ships": ["ship_1", "ship_2"],
			"unlocked_weapons": ["pulselaser1", "rocket1"],
		}
	_save_data()
	return true

func get_current_profile() -> String:
	return current_profile_name

func get_profile_data(profile_name: String = "") -> Dictionary:
	var profile_key = profile_name if not profile_name.is_empty() else current_profile_name
	if profiles.has(profile_key):
		return profiles[profile_key]
	return {}

func get_completed_challenges(profile_name: String = "") -> Dictionary:
	var pdata = get_profile_data(profile_name)
	return pdata.get("completed_challenges", {})

func set_completed_challenge(challenge_id: String, profile_name: String = "") -> void:
	var profile_key = profile_name if not profile_name.is_empty() else current_profile_name
	if not profiles.has(profile_key):
		return
	profiles[profile_key]["completed_challenges"][challenge_id] = true
	_save_data()

func get_unlocked_ships(profile_name: String = "") -> Array:
	var pdata = get_profile_data(profile_name)
	return pdata.get("unlocked_ships", ["ship_1", "ship_2"])

func unlock_ship(ship_id: String, profile_name: String = "") -> void:
	var profile_key = profile_name if not profile_name.is_empty() else current_profile_name
	if not profiles.has(profile_key):
		return
	if not ship_id in profiles[profile_key]["unlocked_ships"]:
		profiles[profile_key]["unlocked_ships"].append(ship_id)
		_save_data()

func get_unlocked_weapons(profile_name: String = "") -> Array:
	var pdata = get_profile_data(profile_name)
	return pdata.get("unlocked_weapons", ["pulselaser1", "rocket1"])

func unlock_weapon(weapon_id: String, profile_name: String = "") -> void:
	var profile_key = profile_name if not profile_name.is_empty() else current_profile_name
	if not profiles.has(profile_key):
		return
	if not weapon_id in profiles[profile_key]["unlocked_weapons"]:
		profiles[profile_key]["unlocked_weapons"].append(weapon_id)
		_save_data()

func has_profile() -> bool:
	return not current_profile_name.is_empty()

# Leaderboard Management
func submit_score(profile_name: String, time: int, level: int, kills: int = 0, ship_id: String = "ship_1") -> void:
	# Create new entry
	var entry = {
		"profile_name": profile_name,
		"time": time,
		"level": level,
		"kills": kills,
		"ship_id": ship_id,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	# Check if this profile + ship combo already has an entry
	var existing_index = -1
	for i in range(leaderboard_entries.size()):
		if leaderboard_entries[i]["profile_name"] == profile_name and leaderboard_entries[i].get("ship_id", "ship_1") == ship_id:
			existing_index = i
			break
	
	# Only update if this is a better score (more kills)
	if existing_index >= 0:
		var old_kills = leaderboard_entries[existing_index].get("kills", 0)
		if kills > old_kills:
			leaderboard_entries[existing_index] = entry
			print("New personal best for %s! Kills: %d" % [ship_id, kills])
		else:
			print("Score submitted for %s: %d kills (not a personal best)" % [ship_id, kills])
	else:
		leaderboard_entries.append(entry)
		print("First score recorded for %s! Kills: %d" % [ship_id, kills])
	
	# Sort by kills (descending - highest kills first), then by time as tiebreaker
	leaderboard_entries.sort_custom(func(a, b):
		var a_kills = a.get("kills", 0)
		var b_kills = b.get("kills", 0)
		if a_kills == b_kills:
			return a.get("time", 0) > b.get("time", 0)
		return a_kills > b_kills
	)
	
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
		"leaderboard": leaderboard_entries,
		"profiles": profiles
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
		profiles = data.get("profiles", {})
