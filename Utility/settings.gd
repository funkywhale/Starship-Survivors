extends Node

const CONFIG_PATH := "user://settings.cfg"

var master_volume: float = 1.0
var music_volume: float = 1.0

func _ready() -> void:
    _load()
    _apply_volumes()

func _load() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(CONFIG_PATH) == OK:
        master_volume = float(cfg.get_value("audio", "master", 1.0))
        music_volume = float(cfg.get_value("audio", "music", 1.0))

func _save() -> void:
    var cfg := ConfigFile.new()
    cfg.set_value("audio", "master", master_volume)
    cfg.set_value("audio", "music", music_volume)
    cfg.save(CONFIG_PATH)

func _apply_volumes() -> void:
    var master_idx := AudioServer.get_bus_index("Master")
    var music_idx := AudioServer.get_bus_index("Music")
    if master_idx >= 0:
        AudioServer.set_bus_volume_db(master_idx, _linear_to_db(master_volume))
    if music_idx >= 0:
        AudioServer.set_bus_volume_db(music_idx, _linear_to_db(music_volume))

func set_master_volume(v: float) -> void:
    master_volume = clamp(v, 0.0, 1.0)
    _apply_volumes()
    _save()

func set_music_volume(v: float) -> void:
    music_volume = clamp(v, 0.0, 1.0)
    _apply_volumes()
    _save()

func get_master_volume() -> float:
    return master_volume

func get_music_volume() -> float:
    return music_volume

func _linear_to_db(l: float) -> float:
    if l <= 0.0001:
        return -60.0
    return lerp(-60.0, 0.0, clamp(l, 0.0, 1.0))
