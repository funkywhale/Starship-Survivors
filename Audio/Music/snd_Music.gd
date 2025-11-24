extends AudioStreamPlayer

# Playlist - add or remove songs here
var playlist = [
	preload("res://Audio/Music/battleThemeA.mp3"),
	preload("res://Audio/Music/battleThemeB.mp3"),
	preload("res://Audio/Music/battleThemeC.mp3"),
]

var current_track_index = 0

func _ready():
	if playlist.size() > 0:
		stream = playlist[current_track_index]

		if stream:
			stream.loop = false
		

		volume_db = -80
		play()

		var tween = create_tween()
		tween.tween_property(self, "volume_db", -10, 1.5)

func _on_player_playerdeath():
	playing = false

func _on_finished() -> void:
	current_track_index = (current_track_index + 1) % playlist.size()
	stream = playlist[current_track_index]
	# Disable looping on the new track
	if stream:
		stream.loop = false
	play()
