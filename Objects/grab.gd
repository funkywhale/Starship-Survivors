extends Area2D

# The grab collectible works by magnetizing all existing experience orbs
# towards the player when collected

var target = null
var speed: float = -1.0
const ACCELERATION: float = 100.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready():
	add_to_group("grab_collectible")

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += ACCELERATION * delta

func collect() -> void:
	"""Called when player collects this grab item"""
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	
	# Get the player directly since target might not be set if we skip the grab area
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("trigger_grab_magnetize"):
		player.trigger_grab_magnetize()

func _on_snd_collected_finished():
	queue_free()
