extends Node2D

# Experience Orb Culling System
# Similar to Vampire Survivors - culls off-screen orbs and combines them into a mega orb

@export var max_offscreen_orbs: int = 50 # Max number of off-screen orbs before culling
@export var check_interval: float = 2.0 # How often to check for culling (in seconds)
@export var screen_margin: float = 100.0 # Distance off-screen before considered for culling

var mega_orb_scene: PackedScene = preload("res://Objects/experience_orb.tscn")
var check_timer: float = 0.0

@onready var player: CharacterBody2D = null
@onready var camera: Camera2D = null


func _ready() -> void:
	# Wait a frame for player to be ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_node_or_null("Camera2D")


func _process(delta: float) -> void:
	check_timer += delta
	if check_timer >= check_interval:
		check_timer = 0.0
		check_and_cull_orbs()


func check_and_cull_orbs() -> void:
	if not player or not camera:
		return
	
	var all_orbs = get_tree().get_nodes_in_group("loot")
	if all_orbs.is_empty():
		return
	
	# Filter to only experience orbs (not other loot)
	var experience_orbs = []
	for orb in all_orbs:
		if orb.has_method("collect") and "experience" in orb:
			experience_orbs.append(orb)
	
	# Get viewport dimensions
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera.global_position
	var half_width = viewport_size.x / 2.0 + screen_margin
	var half_height = viewport_size.y / 2.0 + screen_margin
	
	# Separate on-screen and off-screen orbs
	var offscreen_orbs = []
	
	for orb in experience_orbs:
		var orb_pos = orb.global_position
		var relative_pos = orb_pos - camera_pos
		
		# Check if orb is outside the screen bounds (with margin)
		if abs(relative_pos.x) > half_width or abs(relative_pos.y) > half_height:
			offscreen_orbs.append(orb)
	
	# If we have too many off-screen orbs, cull them
	if offscreen_orbs.size() >= max_offscreen_orbs:
		cull_and_combine_orbs(offscreen_orbs, camera_pos, viewport_size)


func cull_and_combine_orbs(orbs: Array, camera_pos: Vector2, viewport_size: Vector2) -> void:
	if orbs.is_empty():
		return
	
	# Calculate total experience from all off-screen orbs
	var total_experience = 0
	for orb in orbs:
		total_experience += orb.experience
		orb.queue_free() # Remove the orb
	
	# Create a mega orb at the edge of the screen
	var mega_orb = mega_orb_scene.instantiate()
	mega_orb.experience = total_experience
	
	# Calculate spawn position at edge of screen (closest to player)
	var spawn_pos = get_edge_spawn_position(camera_pos, viewport_size)
	mega_orb.global_position = spawn_pos
	
	# Force the mega orb to use red sprite
	mega_orb.sprite.texture = mega_orb.spr_red
	
	# Add to the loot group parent
	var loot_base = get_tree().get_first_node_in_group("loot")
	if loot_base:
		loot_base.call_deferred("add_child", mega_orb)
	
	print("Culled ", orbs.size(), " orbs. Created mega orb with ", total_experience, " experience at ", spawn_pos)


func get_edge_spawn_position(camera_pos: Vector2, viewport_size: Vector2) -> Vector2:
	# Spawn at a random edge of the screen
	var half_width = viewport_size.x / 2.0
	var half_height = viewport_size.y / 2.0
	
	# Choose a random edge (0=top, 1=right, 2=bottom, 3=left)
	var edge = randi() % 4
	var spawn_pos = camera_pos
	
	match edge:
		0: # Top
			spawn_pos.x += randf_range(-half_width * 0.8, half_width * 0.8)
			spawn_pos.y -= half_height * 0.9
		1: # Right
			spawn_pos.x += half_width * 0.9
			spawn_pos.y += randf_range(-half_height * 0.8, half_height * 0.8)
		2: # Bottom
			spawn_pos.x += randf_range(-half_width * 0.8, half_width * 0.8)
			spawn_pos.y += half_height * 0.9
		3: # Left
			spawn_pos.x -= half_width * 0.9
			spawn_pos.y += randf_range(-half_height * 0.8, half_height * 0.8)
	
	return spawn_pos
