extends Area2D

@export var damage = 1
@onready var collision = $CollisionShape2D
@onready var disableTimer = $DisableHitBoxTimer

func tempdisable():
	collision.call_deferred("set","disabled",true)
	disableTimer.start()

func enemy_hit(_amount):
	# Called by hurt_box.gd when this HitBox deals damage
	# Tell the parent enemy to die
	var parent = get_parent()
	if parent and parent.has_method("on_damage_dealt"):
		parent.on_damage_dealt()

func _on_disable_hit_box_timer_timeout():
	collision.call_deferred("set","disabled",false)
