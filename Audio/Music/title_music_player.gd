extends AudioStreamPlayer

var should_play = true

func _ready():
	if not playing and should_play:
		play()
		finished.connect(_on_finished)

func stop_title_music():
	should_play = false
	stop()

func _on_finished():
	if should_play:
		play()
