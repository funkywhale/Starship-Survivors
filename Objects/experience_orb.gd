extends Area2D

@export var experience = 1

var spr_green = preload("res://Textures/Items/Gems/exp_1.png")
var spr_blue = preload("res://Textures/Items/Gems/exp_2.png")
var spr_red = preload("res://Textures/Items/Gems/exp_3.png")

var target = null
var speed: float = -1.0
const ACCELERATION: float = 100.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $snd_collected

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = spr_blue
	else:
		sprite.texture = spr_red

func _physics_process(delta: float) -> void:
	if target != null:
		global_position = global_position.move_toward(target.global_position, speed)
		speed += ACCELERATION * delta

func collect() -> int:
	sound.play()
	collision.call_deferred("set", "disabled", true)
	sprite.visible = false
	return experience


func _on_snd_collected_finished():
	queue_free()
