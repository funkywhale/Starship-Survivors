extends Area2D

var angle: Vector2 = Vector2.ZERO
@export var damage: int = 8
@export var knockback_amount: int = 100
@export var life_time: float = 0.12
@export var radius: float = 36.0

@onready var col = $CollisionShape2D

func _ready():
	$AnimationPlayer.play("explode")
	if col and col.shape and col.shape is CircleShape2D:
		col.shape.radius = radius
	var t = Timer.new()
	t.wait_time = life_time
	t.one_shot = true
	add_child(t)
	t.connect("timeout", Callable(self, "queue_free"))
	t.start()
	if not is_in_group("attack"):
		add_to_group("attack")
	if not has_meta("angle"):
		self.angle = Vector2.ZERO
