extends Control

@export_file("*.tscn") var game_scene_path: String
@export var playbutton : Button
@export var quitbutton : Button
@export var clickSfx : AudioStream
@export var bgm : AudioStream
@export var ambitience : AudioStream
@export var music_strength : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.play_music(bgm,music_strength)
	AudioManager.play_ambietence(ambitience)
	quitbutton.pressed.connect(OnQuit)
	playbutton.pressed.connect(OnPlay)

func OnQuit():
	SceneManager.quit_game()
	
func OnPlay():
	AudioManager.play_sfx(clickSfx)
	SceneManager.change_scene(game_scene_path)
