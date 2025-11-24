extends CharacterBody2D

# Gentle random movement and rotation for rocks
var drift_velocity: Vector2
var angular_velocity: float
var min_speed := 2.0
var max_speed := 8.0
var min_angular := 0.02
var max_angular := 0.08
var bounce_damping := 0.8 # How much energy is retained after bounce

func _ready():
	# Determine rock size by scene name or property
	var size = "small"
	if name.find("medium") != -1:
		size = "medium"
	elif name.find("large") != -1:
		size = "large"

	# Adjust speed/rotation ranges by size
	match size:
		"small":
			min_speed = 2.0
			max_speed = 8.0
			min_angular = 0.02
			max_angular = 0.08
		"medium":
			min_speed = 1.0
			max_speed = 4.0
			min_angular = 0.01
			max_angular = 0.04
		"large":
			min_speed = 0.5
			max_speed = 2.0
			min_angular = 0.005
			max_angular = 0.02

	# Set a gentle random velocity
	var angle = randf() * TAU
	var speed = randf_range(min_speed, max_speed)
	drift_velocity = Vector2(cos(angle), sin(angle)) * speed

	# Set a gentle random angular velocity
	angular_velocity = randf_range(min_angular, max_angular) * (1 if randf() > 0.5 else -1)

	# Collide with player (layer 1) and other rocks (layer 2)
	collision_layer = 1 + 2 # On layers 1 and 2
	collision_mask = 2 # Only collide with other rocks (layer 2)

	# Randomize initial rotation
	rotation = randf() * TAU

func _physics_process(delta: float) -> void:
	# Set velocity for movement
	velocity = drift_velocity
	
	# Move and check for collisions
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		# Bounce off gently when hitting another rock
		drift_velocity = drift_velocity.bounce(collision.get_normal()) * bounce_damping
		
		# Add slight random variation to prevent rocks from getting stuck
		drift_velocity += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	
	# Rotate
	rotation += angular_velocity * delta
