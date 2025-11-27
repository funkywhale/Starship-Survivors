extends RayCast2D
var level: int = 1
var damage: int = 15
var knockback_amount: int = 50
var attack_size: float = 1.0
var max_length: float = 300.0
var grow_speed: float = 700.0
var sustain_time: float = 0.25
var fade_time: float = 0.15
var weapon_id: String = "ionlaser"
var lifetime: float = 0.0
var appearing: bool = true
var disappearing: bool = false
var beam_tween: Tween
var hit_enemies: Array = []
var is_critical: bool = false

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")
@onready var beam_line: Line2D = $BeamLine
@onready var glow_line: Line2D = $GlowLine
@onready var snd_player: AudioStreamPlayer = $snd_play
@onready var hit_area: Area2D = $HitArea
@onready var hit_shape: CollisionShape2D = $HitArea/CollisionShape2D

signal remove_from_array(object)

func _ready() -> void:
	add_to_group("attack")
	
	# Check for critical strike
	if player and player.has_method("roll_critical"):
		is_critical = player.roll_critical()
	
	if player:
		_update_from_level()

	beam_line.clear_points()
	glow_line.clear_points()
	var origin = Vector2.ZERO
	beam_line.add_point(origin)
	beam_line.add_point(origin)
	glow_line.add_point(origin)
	glow_line.add_point(origin)
	beam_line.default_color = Color(0.7, 0.85, 1.0, 0.95) # Cyan-blue core
	glow_line.modulate = Color(0.6, 0.75, 1.0, 0.85) # Blue-ish glow
	beam_line.width = 3.0 * attack_size
	glow_line.width = 8.0 * attack_size

	beam_tween = create_tween()
	beam_line.width = 0.0
	glow_line.width = 0.0
	beam_tween.tween_property(beam_line, "width", 3.0 * attack_size, fade_time * 2.0).from(0.0)
	beam_tween.parallel().tween_property(glow_line, "width", 8.0 * attack_size, fade_time * 2.0).from(0.0)
	snd_player.play()
	if hit_area:
		var rect := RectangleShape2D.new()
		hit_shape.shape = rect
		hit_area.area_entered.connect(_on_hit_area_area_entered)

func _update_from_level() -> void:
	level = player.ionlaser_level
	var stats = WeaponRegistry.get_weapon_stats(weapon_id, level)
	
	if stats.is_empty():
		push_error("IonLaser: Failed to get stats for level %d" % level)
		return
	
	damage = stats.get("damage", 10) + player.damage_bonus
	max_length = stats.get("max_length", 100.0) * (1 + player.spell_size)
	attack_size = stats.get("attack_size", 1.0) * (1 + player.spell_size)
	grow_speed = stats.get("grow_speed", 100.0)
	knockback_amount = int(50 * (1.0 + player.knockback_multiplier))
	
	if is_critical:
		damage *= 2
	
	# Adjust widths if already initialized
	if beam_line:
		beam_line.width = 3.0 * attack_size
	if glow_line:
		glow_line.width = 8.0 * attack_size

func _physics_process(delta: float) -> void:
	lifetime += delta
	# Extend toward target length
	var target_len = max_length
	var current_len = min(target_len, target_position.x + grow_speed * delta)
	target_position.x = current_len
	force_raycast_update()
	var end_point = Vector2.RIGHT * current_len
	if is_colliding():
		end_point = to_local(get_collision_point())
	# Update line points
	beam_line.set_point_position(0, Vector2.RIGHT * 0)
	beam_line.set_point_position(1, end_point)
	glow_line.set_point_position(0, Vector2.RIGHT * 0)
	glow_line.set_point_position(1, end_point)
	# Resize hit area collision shape to cover beam span
	if hit_shape and hit_shape.shape is RectangleShape2D:
		var rect := hit_shape.shape as RectangleShape2D
		rect.size = Vector2(max(end_point.x, 1.0), max(beam_line.width * 2.0, 2.0))
		hit_area.position = Vector2.RIGHT * (end_point.x * 0.5)
		hit_area.rotation = global_rotation
	# Pulse effect
	var pulse = 1.0 + 0.10 * sin(lifetime * 16.0)
	beam_line.width = (3.0 * attack_size) * pulse
	glow_line.width = (8.0 * attack_size) * pulse

	# Shape query damage (multi-hit across beam span) - reduce frequency for performance
	if int(lifetime * 60.0) % 2 == 0: # Every other frame
		_apply_shape_query_damage(end_point.x)
	# Sustain then disappear
	if lifetime >= sustain_time and not disappearing:
		_start_disappear()
	# Damage application (continuous hit scan)
	elif is_colliding(): # still apply impact damage at tip once
		_var_damage_application()
	# Apply damage to enemies newly entering beam via area_entered (handled by signal)

func _start_disappear() -> void:
	disappearing = true
	if beam_tween and beam_tween.is_running():
		beam_tween.kill()
	beam_tween = create_tween()
	beam_tween.tween_property(beam_line, "width", 0.0, fade_time).from(beam_line.width)
	beam_tween.parallel().tween_property(glow_line, "width", 0.0, fade_time).from(glow_line.width)
	beam_tween.tween_callback(Callable(self, "_queue_remove"))

func _queue_remove() -> void:
	emit_signal("remove_from_array", self)
	queue_free()

func _var_damage_application() -> void:
	var collider = get_collider()
	if collider == null:
		return
	var hurt_box = null
	if collider.has_node("HurtBox"):
		hurt_box = collider.get_node("HurtBox")
	elif collider.get_parent() and collider.get_parent().has_node("HurtBox"):
		hurt_box = collider.get_parent().get_node("HurtBox")
	if hurt_box and hurt_box.has_signal("hurt"):
		var enemy = hurt_box.get_parent()
		if enemy and hit_enemies.has(enemy):
			return
		hurt_box.emit_signal("hurt", damage, Vector2.RIGHT.rotated(global_rotation), knockback_amount)
		if enemy and not hit_enemies.has(enemy):
			hit_enemies.append(enemy)

func _on_hit_area_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return

	if area.has_signal("hurt"):
		var enemy = area.get_parent()
		if enemy and hit_enemies.has(enemy):
			return
		area.emit_signal("hurt", damage, Vector2.RIGHT.rotated(global_rotation), knockback_amount)
		if enemy and not hit_enemies.has(enemy):
			hit_enemies.append(enemy)

func _apply_shape_query_damage(current_len: float) -> void:
	# Build rectangle covering beam; center point half-way along global direction
	if current_len <= 2.0:
		return
	var shape := RectangleShape2D.new()
	shape.size = Vector2(current_len, max(beam_line.width * 2.0, 2.0))
	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	# Transform2D takes (rotation, position); position is global center of rectangle
	var dir := Vector2.RIGHT.rotated(global_rotation)
	params.transform = Transform2D(global_rotation, global_position + dir * (current_len * 0.5))
	# Enemy root bodies use layer 4; query that
	params.collision_mask = 4
	params.exclude = []
	var results = get_world_2d().direct_space_state.intersect_shape(params, 16)
	for res in results:
		var collider = res.get("collider")
		if collider == null:
			continue
		# collider is likely the enemy body; find its HurtBox child
		var hurt_box = null
		if collider.has_node("HurtBox"):
			hurt_box = collider.get_node("HurtBox")
		elif collider.get_parent() and collider.get_parent().has_node("HurtBox"):
			# In case we hit a child of the enemy body
			hurt_box = collider.get_parent().get_node("HurtBox")
		if hurt_box and hurt_box.has_signal("hurt"):
			var enemy = hurt_box.get_parent()
			if enemy and hit_enemies.has(enemy):
				continue
			hurt_box.emit_signal("hurt", damage, dir, knockback_amount)
			if enemy and not hit_enemies.has(enemy):
				hit_enemies.append(enemy)

func enemy_hit(_charge: int = 1) -> void:
	# Ion laser persists; ignore.
	pass
