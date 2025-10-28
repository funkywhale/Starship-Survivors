extends Node

# Engagement-optimized difficulty manager
# Tracks player performance and adjusts enemy spawning to maintain optimal challenge

# Performance tracking
var total_damage_taken = 0.0
var damage_in_last_10_sec = 0.0
var time_alive = 0.0
var enemies_killed = 0
var kills_in_last_10_sec = 0

# Consecutive damage tracking
var last_damage_time = 0.0
var damage_streak = 0  # How many hits in quick succession
var damage_streak_window = 3.0  # Reset streak if no damage for 3 seconds
var damage_events_this_interval = 0  # Count of separate damage events

# Difficulty metrics - fully dynamic, no hard limits
var current_difficulty = 1.0  # 1.0 is baseline, scales dynamically based on performance
var target_difficulty = 1.0

# Performance analysis
var performance_check_interval = 5.0  # Check every 5 seconds
var performance_timer = 0.0

# Thresholds for adjustment
const PERFORM_VERY_WELL = 1.5    # Player doing great, increase difficulty
const PERFORM_WELL = 1.2         # Player doing good, slightly increase
const PERFORM_AVERAGE = 0.8      # Player doing okay, maintain
const PERFORM_POORLY = 0.5       # Player struggling, decrease difficulty

# Rate of change - MUCH more aggressive for better engagement
const DIFFICULTY_CHANGE_RATE = 0.50  

# Metrics for the last interval
var last_check_time = 0.0
var damage_this_interval = 0.0
var kills_this_interval = 0

func _ready():
	reset_stats()

func _process(delta):
	time_alive += delta
	performance_timer += delta

	if performance_timer >= performance_check_interval:
		_evaluate_performance()
		performance_timer = 0.0

func reset_stats():
	total_damage_taken = 0.0
	damage_in_last_10_sec = 0.0
	time_alive = 0.0
	enemies_killed = 0
	kills_in_last_10_sec = 0
	current_difficulty = 1.0
	target_difficulty = 1.0
	performance_timer = 0.0
	damage_this_interval = 0.0
	kills_this_interval = 0
	damage_streak = 0
	last_damage_time = 0.0
	damage_events_this_interval = 0

func record_damage(amount: float):
	total_damage_taken += amount
	damage_this_interval += amount
	damage_events_this_interval += 1

	# Track consecutive damage (damage streak)
	var time_since_last_damage = time_alive - last_damage_time
	if time_since_last_damage < damage_streak_window:
		damage_streak += 1
	else:
		damage_streak = 1  # Reset streak

	last_damage_time = time_alive

	# Debug logging
	print("DAMAGE: %.1f damage taken | Streak: %d | Total this interval: %.1f | Events: %d" %
		  [amount, damage_streak, damage_this_interval, damage_events_this_interval])

func record_kill():
	enemies_killed += 1
	kills_this_interval += 1

func _evaluate_performance():
	# Calculate performance score based on multiple factors
	var performance_score = 1.0

	# Factor 1: Damage taken rate AND consecutive damage pattern
	# Check both total damage and frequency of hits
	var expected_damage = performance_check_interval * 1.0  # Expect ~1 damage per second baseline
	var damage_multiplier = 1.0

	# Penalize based on total damage - MUCH MORE EXTREME
	if damage_this_interval == 0:
		# No damage - player is dominating, crank it up!
		damage_multiplier *= 2.0
	elif damage_this_interval < expected_damage * 0.3:
		# Very little damage - player is skilled
		damage_multiplier *= 1.6
	elif damage_this_interval < expected_damage:
		# Low damage - player is doing well
		damage_multiplier *= 1.3
	elif damage_this_interval > expected_damage * 3.0:
		# Heavy damage - player is struggling badly
		damage_multiplier *= 0.2
	elif damage_this_interval > expected_damage * 1.5:
		# Moderate-high damage
		damage_multiplier *= 0.4
	else:
		# Taking expected damage
		damage_multiplier *= 0.8

	# CRITICAL: Penalize consecutive damage EXTREMELY heavily
	# If player is getting hit multiple times in quick succession, drop difficulty HARD
	if damage_events_this_interval >= 3:
		# Getting hit 3+ times in 5 seconds - player is overwhelmed, make it MUCH easier
		damage_multiplier *= 0.2
		print("CONSECUTIVE DAMAGE PENALTY: %d hits in interval!" % damage_events_this_interval)
	elif damage_events_this_interval >= 2:
		# Getting hit 2 times - player is struggling
		damage_multiplier *= 0.4

	performance_score *= damage_multiplier

	# Factor 2: Kill rate
	# More kills = player is doing well
	var expected_kills = max(1, int(time_alive / 10.0))  # Expect kills to scale with time
	if kills_this_interval > expected_kills * 1.5:
		# Killing a lot - player is strong
		performance_score *= 1.3
	elif kills_this_interval > expected_kills:
		# Killing well
		performance_score *= 1.1
	elif kills_this_interval < expected_kills * 0.5:
		# Not killing much - player might be struggling
		performance_score *= 0.7

	# Factor 3: Survival time bonus
	# The longer they survive, the more we can challenge them
	if time_alive > 120:  # After 2 minutes
		performance_score *= 1.1
	if time_alive > 180:  # After 3 minutes
		performance_score *= 1.1

	# Adjust target difficulty based on performance - MUCH MORE DRASTIC CHANGES
	if performance_score >= PERFORM_VERY_WELL:
		target_difficulty = current_difficulty + 0.4  # Massive increase
	elif performance_score >= PERFORM_WELL:
		target_difficulty = current_difficulty + 0.25  # Big increase
	elif performance_score >= PERFORM_AVERAGE:
		# Maintain current difficulty
		target_difficulty = current_difficulty
	elif performance_score >= PERFORM_POORLY:
		target_difficulty = current_difficulty - 0.25  # Big decrease
	else:
		# Player is really struggling - drop difficulty hard
		target_difficulty = current_difficulty - 0.5  # Massive decrease

	# Ensure difficulty never goes below 0.1 (but no upper limit)
	target_difficulty = max(0.1, target_difficulty)

	# Smoothly adjust current difficulty toward target
	current_difficulty = lerp(current_difficulty, target_difficulty, DIFFICULTY_CHANGE_RATE)

	# Reset interval stats
	damage_this_interval = 0.0
	kills_this_interval = 0
	damage_events_this_interval = 0

	# Debug info
	print("=== DIFFICULTY UPDATE === Time: %.1f | Performance: %.2f | Difficulty: %.2f | Kills: %d | Total Damage: %.1f | Target: %.2f" %
		  [time_alive, performance_score, current_difficulty, enemies_killed, total_damage_taken, target_difficulty])

# Get difficulty multipliers for spawning
func get_spawn_rate_multiplier() -> float:
	# Higher difficulty = faster spawns
	return current_difficulty

func get_enemy_count_multiplier() -> float:
	# Higher difficulty = more enemies
	return current_difficulty

func get_difficulty_level() -> float:
	return current_difficulty

# Get a text description of current difficulty (dynamic based on actual value)
func get_difficulty_description() -> String:
	return "x%.2f" % current_difficulty
