extends AudioStreamPlayer

var should_play = true

func _ready():
	# Apply persisted music volume if Settings autoload is present.
	var settings := get_node_or_null("/root/Settings")
	if settings:
		var music_idx := AudioServer.get_bus_index("Music")
		if music_idx >= 0:
			var mv: float = settings.get_music_volume()
			var db: float = -80.0 if mv <= 0.0001 else lerp(-80.0, 0.0, clamp(mv, 0.0, 1.0))
			AudioServer.set_bus_volume_db(music_idx, db)

	if not playing and should_play:
		play()
		finished.connect(_on_finished)

func stop_title_music():
	should_play = false
	stop()

func start_title_music():
	should_play = true
	if not playing:
		play()

func _on_finished():
	if should_play:
		play()
