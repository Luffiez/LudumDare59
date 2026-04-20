extends Node2D

class_name  GhostSpawner

@export var spawn_line : SpawnLine
@export var ghost_boat_scene : PackedScene
@export var spawn_timer : Timer
@export var reduce_spawn_time_timer : Timer
@export var start_spawn_time : float
@export var min_spawn_time : float
@export var reduce_spawn_timer_time: float
@export var spawn_time_reducement:float
@export var target : Lighthouse
@export var game_ui: GameUI
@export var max_random_offset : float
var spawn_time : float
var game_over := false

func _ready() -> void:
	spawn_timer.timeout.connect(spawn_enemy)
	spawn_time = start_spawn_time
	reduce_spawn_time_timer.timeout.connect(reduce_spawn_time)
	target.on_game_over.connect(on_game_over)
	spawn_enemy()

func reduce_spawn_time () -> void:
	spawn_time -= spawn_time_reducement
	if  spawn_time < min_spawn_time:
		spawn_time = min_spawn_time
	else:
		reduce_spawn_time_timer.start(reduce_spawn_timer_time)

func on_game_over()->void:
	game_over = true

func spawn_enemy() ->  void :
	if  game_over:
		return
	var random_float := randf_range(0,1)
	spawn_line.set_progress_ratio(random_float)
	var spawn_position =  spawn_line.get_spawn_global_position()
	var new_enemy := ghost_boat_scene.instantiate() as GhostBoat
	add_child(new_enemy)
	new_enemy.ghost_boat_died.connect(game_ui.gain_score)
	target.on_game_over.connect(new_enemy.on_game_over)
	new_enemy.global_position = spawn_position
	new_enemy.set_target(target)
	spawn_time += randf_range(-max_random_offset, max_random_offset)
	if spawn_time < min_spawn_time:
		spawn_time = min_spawn_time
	spawn_timer.start(spawn_time)
