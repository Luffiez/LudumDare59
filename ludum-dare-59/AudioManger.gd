extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

@export var sfx_pool_size := 8

func _ready():
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Bgm"
	add_child(music_player)

	# Create SFX pool
	for i in sfx_pool_size:
		var player = AudioStreamPlayer.new()
		player.bus = "Sfx"
		add_child(player)
		sfx_players.append(player)

func play_music(stream: AudioStream, volume_db := 0.0):
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()

func stop_music():
	music_player.stop()

func play_sfx(stream: AudioStream, volume_db := 0.0):
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
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
