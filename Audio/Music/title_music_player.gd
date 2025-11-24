extends AudioStreamPlayer

var should_play = true

func _ready():
	# Only play if not already playing (in case of scene reloads)
	if not playing and should_play:
		play()
		finished.connect(_on_finished)

func stop_title_music():
	should_play = false
	stop()

func _on_finished():
	# Loop the title music if we haven't stopped it
	if should_play:
		play()
