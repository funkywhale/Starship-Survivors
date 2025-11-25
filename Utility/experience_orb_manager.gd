extends Node2D

@export var cull_delay: float = 10.0
@export var recenter_delay: float = 10.0
@export var check_interval: float = 5.0
@export var screen_margin: float = 120.0
@export var min_offscreen_orbs_to_cull: int = 25
@export var offscreen_orbs_per_minute: int = 10
@export var hard_offscreen_orb_cap: int = 120

var mega_orb_scene: PackedScene = preload("res://Objects/experience_orb.tscn")

var _time_since_last_check: float = 0.0
var _time_since_last_recenter: float = 0.0
var _time_since_start: float = 0.0

var _pending_experience: int = 0
var _pending_orb_count: int = 0

var _mega_orb: Area2D = null

@onready var player: CharacterBody2D = null
@onready var camera: Camera2D = null


func _ready() -> void:
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_node_or_null("Camera2D")
	
	_time_since_last_check = 0.0
	_time_since_last_recenter = 0.0
	_time_since_start = 0.0
	_pending_experience = 0
	_pending_orb_count = 0
	_mega_orb = null


func _process(delta: float) -> void:
	if not player or not camera:
		return
	
	_time_since_last_check += delta
	_time_since_last_recenter += delta
	_time_since_start += delta
	
	if _time_since_last_check >= check_interval:
		_time_since_last_check = 0.0
		_cull_offscreen_orbs()
	
	if _mega_orb and _time_since_last_recenter >= recenter_delay:
		_time_since_last_recenter = 0.0
		_recenter_mega_orb()


func _cull_offscreen_orbs() -> void:
	var all_loot := get_tree().get_nodes_in_group("loot")
	if all_loot.is_empty():
		return
	
	var viewport_size: Vector2 = get_viewport_rect().size
	var cam_pos: Vector2 = camera.global_position
	var half_w: float = viewport_size.x * 0.5 + screen_margin
	var half_h: float = viewport_size.y * 0.5 + screen_margin
	
	var culled: Array = []
	var offscreen_count: int = 0
	
	for node in all_loot:
		if not is_instance_valid(node):
			continue
		if not node.has_method("collect"):
			continue
		if not ("experience" in node):
			continue
		if node == _mega_orb:
			continue
		
		var rel: Vector2 = node.global_position - cam_pos
		if abs(rel.x) > half_w or abs(rel.y) > half_h:
			offscreen_count += 1
			culled.append(node)

	if offscreen_count == 0:
		return

	var minutes_since_start: float = _time_since_start / 60.0
	var dynamic_threshold: int = min_offscreen_orbs_to_cull + int(offscreen_orbs_per_minute * minutes_since_start)
	if offscreen_count < dynamic_threshold and offscreen_count < hard_offscreen_orb_cap:
		return
	
	var added_xp := 0
	for orb in culled:
		if not is_instance_valid(orb):
			continue
		if not ("experience" in orb):
			continue
		added_xp += orb.experience
		orb.queue_free()
	
	if added_xp <= 0:
		return
	
	_pending_experience += added_xp
	_pending_orb_count += culled.size()
	
	if not _mega_orb:
		_spawn_new_mega_orb(cam_pos, viewport_size)
	else:
		_update_mega_orb_value()
	
	_time_since_last_recenter = 0.0


func _spawn_new_mega_orb(cam_pos: Vector2, viewport_size: Vector2) -> void:
	_mega_orb = mega_orb_scene.instantiate()
	_mega_orb.experience = _pending_experience
	
	var spawn_pos: Vector2 = _edge_spawn_position(cam_pos, viewport_size)
	_mega_orb.global_position = spawn_pos
	
	var sprite_node = _mega_orb.get_node_or_null("Sprite2D")
	if sprite_node and typeof(sprite_node) != TYPE_NIL:
		var red_tex: Texture2D = preload("res://Textures/Items/Gems/Gem_red.png")
		if red_tex:
			sprite_node.texture = red_tex
	
	var loot_parent = get_tree().get_first_node_in_group("loot")
	if loot_parent:
		loot_parent.add_child(_mega_orb)
	else:
		add_child(_mega_orb)

	_update_mega_orb_value()


func _update_mega_orb_value() -> void:
	if not _mega_orb:
		return
	if not is_instance_valid(_mega_orb):
		_mega_orb = null
		return
	
	_mega_orb.experience = _pending_experience


func _recenter_mega_orb() -> void:
	if not _mega_orb or not is_instance_valid(_mega_orb):
		_mega_orb = null
		return
	
	var viewport_size: Vector2 = get_viewport_rect().size
	var cam_pos: Vector2 = camera.global_position
	var new_pos: Vector2 = _edge_spawn_position(cam_pos, viewport_size, 0.7)
	_mega_orb.global_position = new_pos


func _edge_spawn_position(cam_pos: Vector2, viewport_size: Vector2, inset: float = 0.9) -> Vector2:
	var half_w: float = viewport_size.x * 0.5
	var half_h: float = viewport_size.y * 0.5
	var edge: int = randi() % 4
	var pos: Vector2 = cam_pos
	
	match edge:
		0:
			pos.x += randf_range(-half_w * inset, half_w * inset)
			pos.y -= half_h * inset
		1:
			pos.x += half_w * inset
			pos.y += randf_range(-half_h * inset, half_h * inset)
		2:
			pos.x += randf_range(-half_w * inset, half_w * inset)
			pos.y += half_h * inset
		3:
			pos.x -= half_w * inset
			pos.y += randf_range(-half_h * inset, half_h * inset)
	
	return pos
