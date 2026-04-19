extends Control

@export var gameScene : PackedScene
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func OnQuit():
	SceneManager.quit_game()
	
func OnPlay():
	AudioManager.play_sfx(clickSfx)
	SceneManager.change_scene(gameScene.get_path())
