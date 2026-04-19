extends Node2D

@export var music : AudioStream
@export var music_strength : float
@export var ambietence : AudioStream

func _ready() -> void:
	
	AudioManager.play_music(music,music_strength)
	var ambitience_playing := false
	ambitience_playing = AudioManager.is_ambietence_playing()
	if  !ambitience_playing:
		AudioManager.play_ambietence(ambietence)
