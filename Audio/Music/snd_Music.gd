extends AudioStreamPlayer

# Playlist - add or remove songs here
var playlist = [
	preload("res://Audio/Music/battleThemeA.mp3"),
	preload("res://Audio/Music/battlethemeB.mp3"),
	preload("res://Audio/Music/battleThemeC.mp3"),
	preload("res://Audio/Music/battleThemeD.mp3"),
	preload("res://Audio/Music/battleThemeE.mp3"),
	preload("res://Audio/Music/battleThemeF.mp3"),
	preload("res://Audio/Music/battleThemeG.mp3"),
	preload("res://Audio/Music/battleThemeH.mp3"),
	preload("res://Audio/Music/battleThemeI.mp3"),
	preload("res://Audio/Music/battleThemeJ.mp3"),
	preload("res://Audio/Music/battleThemeK.mp3"),
]

var last_track_index = -1

func _ready():
	randomize()
	if playlist.size() > 0:
		_play_random_track()
		
		volume_db = -80
		play()
		
		var tween = create_tween()
		tween.tween_property(self, "volume_db", -15, 2.5)

func _play_random_track() -> void:
	var random_index = randi() % playlist.size()
	

	if playlist.size() > 1:
		while random_index == last_track_index:
			random_index = randi() % playlist.size()
	
	last_track_index = random_index
	stream = playlist[random_index]
	

	if stream:
		stream.loop = false

func _on_player_playerdeath():
	playing = false

func _on_finished() -> void:
	_play_random_track()
	play()
