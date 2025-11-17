extends Node

# Engagement-optimized difficulty manager
# Tracks player performance and adjusts enemy spawning to maintain optimal challenge

# Performance tracking
var total_damage_taken = 0.0
var time_alive = 0.0
var enemies_killed = 0

# Consecutive damage tracking
var last_damage_time = 0.0
var damage_streak = 0
var damage_streak_window = 3.0
var damage_events_this_interval = 0

# Difficulty metrics - carefully balanced
var current_difficulty = 1.0
var target_difficulty = 1.0

# Difficulty bounds - prevents extremes
var min_difficulty = 0.4  # Never go below 40% difficulty
var max_difficulty = 1.8  # Start capped at 1.8x, increases with time

# Performance analysis
var performance_check_interval = 5.0
var performance_timer = 0.0

# Adjusted thresholds for balanced gameplay
const PERFORM_VERY_WELL = 1.35
const PERFORM_WELL = 1.15
const PERFORM_AVERAGE = 0.85
const PERFORM_POORLY = 0.65

# Smooth difficulty changes
const DIFFICULTY_CHANGE_RATE = 0.20

# Metrics for the last interval
var damage_this_interval = 0.0
var kills_this_interval = 0

# NEW: Track if difficulty was recently reduced to prevent yo-yoing
var recently_reduced = false
var reduction_cooldown = 0.0
const REDUCTION_COOLDOWN_TIME = 10.0

func _ready():
	reset_stats()

func _process(delta):
	time_alive += delta
	performance_timer += delta
	
	if reduction_cooldown > 0:
		reduction_cooldown -= delta
		if reduction_cooldown <= 0:
			recently_reduced = false

	if performance_timer >= performance_check_interval:
		_evaluate_performance()
		performance_timer = 0.0

func reset_stats():
	total_damage_taken = 0.0
	time_alive = 0.0
	enemies_killed = 0
	current_difficulty = 1.0
	target_difficulty = 1.0
	performance_timer = 0.0
	damage_this_interval = 0.0
	kills_this_interval = 0
	damage_streak = 0
	last_damage_time = 0.0
	damage_events_this_interval = 0
	recently_reduced = false
	reduction_cooldown = 0.0
	max_difficulty = 1.8

func record_damage(amount: float):
	total_damage_taken += amount
	damage_this_interval += amount
	damage_events_this_interval += 1

	# Track consecutive damage
	var time_since_last_damage = time_alive - last_damage_time
	if time_since_last_damage < damage_streak_window:
		damage_streak += 1
	else:
		damage_streak = 1

	last_damage_time = time_alive

	print("DAMAGE: %.1f damage taken | Streak: %d | Total this interval: %.1f | Events: %d" %
		  [amount, damage_streak, damage_this_interval, damage_events_this_interval])

func record_kill():
	enemies_killed += 1
	kills_this_interval += 1

func _evaluate_performance():
	var performance_score = 1.0

	# Factor 1: Damage Analysis - Most important factor
	var expected_damage = performance_check_interval * 1.2  # Slightly increased baseline
	var damage_multiplier = 1.0

	# Reward taking no/little damage
	if damage_this_interval == 0:
		damage_multiplier *= 1.35
	elif damage_this_interval < expected_damage * 0.4:
		damage_multiplier *= 1.2
	elif damage_this_interval < expected_damage * 0.8:
		damage_multiplier *= 1.1
	# Punish taking heavy damage
	elif damage_this_interval > expected_damage * 2.5:
		damage_multiplier *= 0.45
	elif damage_this_interval > expected_damage * 1.8:
		damage_multiplier *= 0.65
	elif damage_this_interval > expected_damage * 1.3:
		damage_multiplier *= 0.8

	# Consecutive hit penalty - key to preventing overwhelm
	if damage_events_this_interval >= 4:
		damage_multiplier *= 0.5
		print("SEVERE CONSECUTIVE DAMAGE: %d hits!" % damage_events_this_interval)
	elif damage_events_this_interval >= 3:
		damage_multiplier *= 0.7
		print("CONSECUTIVE DAMAGE: %d hits!" % damage_events_this_interval)

	performance_score *= damage_multiplier

	# Factor 2: Kill Rate - Secondary factor
	var expected_kills = max(1, int(current_difficulty * 1.5))
	if kills_this_interval >= expected_kills * 2:
		performance_score *= 1.25
	elif kills_this_interval >= expected_kills * 1.3:
		performance_score *= 1.15
	elif kills_this_interval < expected_kills * 0.6:
		performance_score *= 0.85

	# Factor 3: Gradually raise difficulty ceiling over time
	if time_alive > 90:
		max_difficulty = min(2.2, 2.0)
	if time_alive > 180:
		max_difficulty = min(2.5, 2.2)
	if time_alive > 300:
		max_difficulty = min(2.8, 2.5)

	# Calculate target difficulty with smaller adjustments
	var old_difficulty = current_difficulty
	
	if performance_score >= PERFORM_VERY_WELL:
		# Only increase if not recently reduced (prevents yo-yo)
		if not recently_reduced:
			target_difficulty = current_difficulty + 0.15
		else:
			target_difficulty = current_difficulty + 0.08
	elif performance_score >= PERFORM_WELL:
		if not recently_reduced:
			target_difficulty = current_difficulty + 0.08
		else:
			target_difficulty = current_difficulty + 0.04
	elif performance_score >= PERFORM_AVERAGE:
		# Maintain with tiny drift toward baseline
		target_difficulty = lerp(current_difficulty, 1.0, 0.05)
	elif performance_score >= PERFORM_POORLY:
		target_difficulty = current_difficulty - 0.12
		recently_reduced = true
		reduction_cooldown = REDUCTION_COOLDOWN_TIME
	else:
		# Player struggling badly
		target_difficulty = current_difficulty - 0.25
		recently_reduced = true
		reduction_cooldown = REDUCTION_COOLDOWN_TIME

	# Clamp to bounds
	target_difficulty = clamp(target_difficulty, min_difficulty, max_difficulty)

	# Smooth transition
	current_difficulty = lerp(current_difficulty, target_difficulty, DIFFICULTY_CHANGE_RATE)
	current_difficulty = clamp(current_difficulty, min_difficulty, max_difficulty)

	# Reset interval stats
	damage_this_interval = 0.0
	kills_this_interval = 0
	damage_events_this_interval = 0

	# Enhanced debug
	print("=== DIFFICULTY === Time: %.1fs | Perf: %.2f | Diff: %.2f->%.2f (max: %.2f) | Kills: %d | Dmg: %.1f%s" %
		  [time_alive, performance_score, old_difficulty, current_difficulty, max_difficulty, 
		   enemies_killed, total_damage_taken, " [REDUCED]" if recently_reduced else ""])

# PRIMARY multiplier - controls overall spawn intensity
func get_difficulty_multiplier() -> float:
	# Use a compressed curve for more balanced scaling
	# At 1.0 diff -> 1.0x
	# At 1.5 diff -> 1.22x  
	# At 2.0 diff -> 1.41x
	return pow(current_difficulty, 0.7)

# Keep these for compatibility
func get_spawn_rate_multiplier() -> float:
	return pow(current_difficulty, 0.7)

func get_enemy_count_multiplier() -> float:
	return pow(current_difficulty, 0.7)

func get_difficulty_level() -> float:
	return current_difficulty

func get_difficulty_description() -> String:
	return "x%.2f" % current_difficulty

# Helper functions
func is_player_struggling() -> bool:
	return current_difficulty < 0.7

func is_player_dominating() -> bool:
	return current_difficulty > 1.6 and time_alive > 90
