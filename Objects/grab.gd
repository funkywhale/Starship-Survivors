extends Area2D


var target = null
var speed: float = -1.0
const ACCELERATION: float = 100.0

# Glow / pulse settings
@export var enable_glow: bool = true
@export var glow_color: Color = Color(0.45, 0.7, 1.0, 0.45)
@export var glow_min_scale: float = 1.05
@export var glow_max_scale: float = 2.22
@export var glow_min_alpha: float = 0.28
@export var glow_max_alpha: float = 0.62
@export var glow_duration: float = 1.3

var _glow: Sprite2D = null
var _pulse_time: float = 0.0
var _shared_glow_material: CanvasItemMaterial = null

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

const COLLECT_SFX_COOLDOWN_MS: int = 100

func _should_play_collect_sfx() -> bool:
	var now_ms: int = Time.get_ticks_msec()
	var last_ms: int = 0
	if get_tree().has_meta("collect_sfx_last_ms"):
		last_ms = int(get_tree().get_meta("collect_sfx_last_ms"))
	if now_ms - last_ms < COLLECT_SFX_COOLDOWN_MS:
		return false
	get_tree().set_meta("collect_sfx_last_ms", now_ms)
	return true

func _ready():
	add_to_group("grab_collectible")

	if enable_glow and sprite and sprite.texture:
		_glow = Sprite2D.new()
		_glow.name = "Glow"
		_glow.texture = sprite.texture
		_glow.centered = sprite.centered
		_glow.position = sprite.position

		_glow.z_index = sprite.z_index + 1

		var start_color = glow_color
		start_color.a = glow_min_alpha
		_glow.modulate = start_color
		_glow.scale = sprite.scale * glow_min_scale


		if _shared_glow_material == null:
			_shared_glow_material = CanvasItemMaterial.new()
			_shared_glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_glow.material = _shared_glow_material
		add_child(_glow)


		_pulse_time = 0.0


func _start_glow_pulse() -> void:
	return

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += ACCELERATION * delta

	if enable_glow and _glow and is_instance_valid(_glow):
		_pulse_time += delta
		if _pulse_time > glow_duration * 4.0:
			_pulse_time = fmod(_pulse_time, glow_duration)
		var phase: float = fmod(_pulse_time, glow_duration) / glow_duration
		var angle: float = phase * PI * 2.0 - PI * 0.5
		var s: float = 0.5 + 0.5 * sin(angle)
		var scale_mult: float = lerp(glow_min_scale, glow_max_scale, s)
		_glow.scale = sprite.scale * scale_mult
		var c: Color = glow_color
		c.a = lerp(glow_min_alpha, glow_max_alpha, s)
		_glow.modulate = c

func collect() -> void:
	if _should_play_collect_sfx():
		sound.play()
	collision.call_deferred("set", "disabled", true)

	if _glow and is_instance_valid(_glow):
		_glow.queue_free()
	sprite.visible = false
	

	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("trigger_grab_magnetize"):
		player.trigger_grab_magnetize()

func _on_snd_collected_finished():
	queue_free()
