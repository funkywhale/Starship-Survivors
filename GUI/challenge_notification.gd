extends Control

# Notification popup for challenge completion
# Call show_notification(text) to display

@onready var label = $Label
@onready var timer = $Timer

func _ready():
	visible = false
	label.text = ""
	timer.wait_time = 2.5
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))

func show_notification(text: String):
	label.text = text
	visible = true
	timer.start()

func _on_timer_timeout():
	visible = false
	label.text = ""
