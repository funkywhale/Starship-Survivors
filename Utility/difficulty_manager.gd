extends Node

# Engagement-optimized difficulty manager
# Tracks player performance and adjusts enemy spawning to maintain optimal challenge

# Performance tracking
var total_damage_taken: float = 0.0
var damage_in_last_10_sec: float = 0.0
var time_alive: float = 0.0
var enemies_killed: int = 0
var kills_in_last_10_sec: int = 0

# Consecutive damage tracking
var last_damage_time: float = 0.0
var damage_streak: int = 0 # How many hits in quick succession
var damage_streak_window: float = 3.0 # Reset streak if no damage for 3 seconds
var damage_events_this_interval: int = 0 # Count of separate damage events

# Difficulty metrics - fully dynamic, no hard limits
var current_difficulty: float = 1.0 # 1.0 is baseline, scales dynamically based on performance
var target_difficulty: float = 1.0

# Performance analysis
var performance_check_interval: float = 5.0 # Check every 5 seconds
var performance_timer: float = 0.0

# Thresholds for adjustment
const PERFORM_VERY_WELL = 1.8 # Player doing great, increase difficulty
const PERFORM_WELL = 1.4 # Player doing good, slightly increase
const PERFORM_AVERAGE = 0.8 # Player doing okay, maintain
const PERFORM_POORLY = 0.5 # Player struggling, decrease difficulty

# Rate of change - More gradual for balanced progression
const DIFFICULTY_CHANGE_RATE: float = 0.25

# Metrics for the last interval
var last_check_time: float = 0.0
var damage_this_interval: float = 0.0
var kills_this_interval: int = 0

func _ready() -> void:
	reset_stats()

func _process(delta: float) -> void:
	time_alive += delta
	performance_timer += delta

	if performance_timer >= performance_check_interval:
		_evaluate_performance()
		performance_timer = 0.0

func reset_stats() -> void:
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

func record_damage(amount: float) -> void:
	total_damage_taken += amount
	damage_this_interval += amount
	damage_events_this_interval += 1

	# Track consecutive damage (damage streak)
	var time_since_last_damage = time_alive - last_damage_time
	if time_since_last_damage < damage_streak_window:
		damage_streak += 1
	else:
		damage_streak = 1 # Reset streak

	last_damage_time = time_alive

func record_kill():
	enemies_killed += 1
	kills_this_interval += 1

func _evaluate_performance():
	# Calculate performance score based on multiple factors
	var performance_score = 1.0

	# Factor 1: Damage taken rate AND consecutive damage pattern
	# Check both total damage and frequency of hits
	var expected_damage = performance_check_interval * 1.0 # Expect ~1 damage per second baseline
	var damage_multiplier = 1.0

	# Penalize based on total damage - More balanced scaling
	if damage_this_interval == 0:
		# No damage - player is doing great
		damage_multiplier *= 1.4
	elif damage_this_interval < expected_damage * 0.3:
		# Very little damage - player is skilled
		damage_multiplier *= 1.25
	elif damage_this_interval < expected_damage:
		# Low damage - player is doing well
		damage_multiplier *= 1.1
	elif damage_this_interval > expected_damage * 3.0:
		# Heavy damage - player is struggling badly
		damage_multiplier *= 0.4
	elif damage_this_interval > expected_damage * 1.5:
		# Moderate-high damage
		damage_multiplier *= 0.6
	else:
		# Taking expected damage
		damage_multiplier *= 0.9

	# Penalize consecutive damage when player is getting overwhelmed
	if damage_events_this_interval >= 4:
		# Getting hit 4+ times in 5 seconds - player is overwhelmed
		damage_multiplier *= 0.5
	elif damage_events_this_interval >= 3:
		# Getting hit 3 times - player is struggling
		damage_multiplier *= 0.7

	performance_score *= damage_multiplier

	# Factor 2: Kill rate
	# More kills = player is doing well
	var expected_kills = max(1, int(time_alive / 10.0)) # Expect kills to scale with time
	if kills_this_interval > expected_kills * 2.0:
		# Killing a lot - player is strong
		performance_score *= 1.2
	elif kills_this_interval > expected_kills * 1.3:
		# Killing well
		performance_score *= 1.08
	elif kills_this_interval < expected_kills * 0.5:
		# Not killing much - player might be struggling
		performance_score *= 0.8

	# Factor 3: Survival time bonus
	# The longer they survive, the more we can challenge them
	if time_alive > 120: # After 2 minutes
		performance_score *= 1.05
	if time_alive > 240: # After 4 minutes
		performance_score *= 1.05
	# Reduce growth rate after 4 minutes to prevent performance issues
	if time_alive > 240 and current_difficulty > 1.5:
		performance_score *= 0.95 # Slow down difficulty increases

	# Adjust target difficulty based on performance - Gradual scaling
	if performance_score >= PERFORM_VERY_WELL:
		target_difficulty = current_difficulty + 0.15 # Moderate increase
	elif performance_score >= PERFORM_WELL:
		target_difficulty = current_difficulty + 0.08 # Small increase
	elif performance_score >= PERFORM_AVERAGE:
		# Maintain current difficulty
		target_difficulty = current_difficulty
	elif performance_score >= PERFORM_POORLY:
		target_difficulty = current_difficulty - 0.15 # Moderate decrease
	else:
		# Player is really struggling - reduce difficulty
		target_difficulty = current_difficulty - 0.25 # Significant decrease

	# Ensure difficulty stays in reasonable bounds
	target_difficulty = clamp(target_difficulty, 0.1, 2.5) # Cap at 2.5x for performance

	# Smoothly adjust current difficulty toward target
	current_difficulty = lerp(current_difficulty, target_difficulty, DIFFICULTY_CHANGE_RATE)
	
	# Soft cap: Above 2.0, make it harder to increase further
	if current_difficulty > 2.0:
		current_difficulty = 2.0 + (current_difficulty - 2.0) * 0.5

	# Reset interval stats
	damage_this_interval = 0.0
	kills_this_interval = 0
	damage_events_this_interval = 0

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
