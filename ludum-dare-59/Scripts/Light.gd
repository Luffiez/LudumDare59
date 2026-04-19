# Lighthouse.gd
class_name Light
extends Node2D

@export var cone_length: float = 300.0
@export var cone_angle: float = 0.3  # radians (~17 degrees)
@export var rotation_speed: float = 0.8  # radians per second
@export var rotation_speed_boosted: float = 0.8  # radians per second
@export var gameover_decrease_speed: float = 0.5  # radians per second
@export var slow_sfx : AudioStream
@export var fast_sfx : AudioStream
@export var gameover_sfx : AudioStream

var isStopped : bool
var gameOver : bool
var playedSfx : bool

func _ready():
	var size = get_viewport().get_visible_rect().size
	var center = Vector2(size.x / 2, size.y /2)
	var parent = get_parent()
	parent.global_position = center
	(parent as Lighthouse).on_game_over.connect(on_game_over)
	
	Darkness.register_revealer(self, DarknessManager.Shape.CONE, {
		"length": cone_length,
		"angle": cone_angle,
		"start_radius": 5
	})

func _process(delta):
	if gameOver:
		game_over_logic(delta)
		return
	
	isStopped = Input.is_action_pressed("stop")
	if(isStopped):
		return
	
	var boosted = Input.is_action_pressed("speed")
	var facing_down = is_facing_down()
	# Darkness reads rotation automatically
	if(boosted):
		rotation += rotation_speed_boosted * delta  
	else:
		rotation += rotation_speed * delta  
	
	if facing_down:
		if !playedSfx:
			playedSfx = true;
			if boosted:
				AudioManager.play_sfx(fast_sfx, -10)
			else:
				AudioManager.play_sfx(slow_sfx, -10)
	elif playedSfx:
		playedSfx = false

func _exit_tree():
	Darkness.unregister_revealer(self)
	
func on_game_over():
	gameOver = true
	AudioManager.play_sfx(gameover_sfx)
	
func game_over_logic(delta):
	rotation_speed += gameover_decrease_speed * delta
	if(rotation_speed >= 0):
		Darkness.unregister_revealer(self)
		set_process(false)
		
	rotation += rotation_speed * delta

func is_facing_down() -> bool:
	return sin(global_rotation) > 0.9
