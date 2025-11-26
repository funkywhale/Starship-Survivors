extends Area2D

var damage: int = 3
var knockback_amount: int = 20
var angle: Vector2 = Vector2.ZERO

func _on_lifetime_timer_timeout() -> void:
	queue_free()
