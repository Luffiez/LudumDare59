extends Node

var music_player: AudioStreamPlayer
var ambietience_player : AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

@export var sfx_pool_size := 8

func _ready():
	# Create music player
	ambietience_player =  AudioStreamPlayer.new()
	ambietience_player.bus = "Amb"
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Bgm"
	add_child(music_player)
	add_child(ambietience_player)

	# Create SFX pool
	for i in sfx_pool_size:
		var player = AudioStreamPlayer.new()
		player.bus = "Sfx"
		add_child(player)
		sfx_players.append(player)

func is_ambietence_playing()->bool:
	return ambietience_player.playing

func play_music(stream: AudioStream, volume_db := 0.0):
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()
	
func play_ambietence (stream: AudioStream, volume_db := 0.0) -> void:
	ambietience_player.stream = stream
	ambietience_player.volume_db = volume_db
	ambietience_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream, volume_db := 0.0, pitch :=1):
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.pitch_scale = pitch
			player.play()
			return

	# fallback if all players busy
	sfx_players[0].stream = stream
	sfx_players[0].play()

func set_music_volume(volume_db: float):
	music_player.volume_db = volume_db

func set_sfx_volume(volume_db: float):
	for player in sfx_players:
		player.volume_db = volume_db
