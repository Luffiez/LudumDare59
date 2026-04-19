extends Node2D

@export var music : AudioStream
@export var music_strength : float
@export var ambietence : AudioStream

func _ready() -> void:
	
	AudioManager.play_music(music,music_strength)
	var ambience_playing := false
	ambience_playing = AudioManager.is_ambience_playing()
	if  !ambience_playing:
		AudioManager.play_ambience(ambietence)
