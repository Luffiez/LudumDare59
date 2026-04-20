extends Node2D

class_name  GhostBoat
const  lightHouseNodeName := "Lighthouse"

@export var collider : Area2D
@export var animatedSprite: AnimatedSprite2D
@export var indicator : Node2D
@export var visibleNotifier : VisibleOnScreenNotifier2D
@export var slow_movement_timer : Timer 
@export var life : float
@export var normal_movement_speed: float
@export var outside_screen_speed: float
@export var flee_movement_speed: float
@export var slow_movement_speed:float
@export var slow_movement_time : float
@export var run_sfx : AudioStream
@export var flee_sfx : Array[AudioStream]
@export var game_over_sfx : Array[AudioStream]
@export var spawn_sfx : Array[AudioStream]
@export var min_pitch : float
@export var max_pitch : float

var light_house_direction := Vector2(0,0)
var flee := false
var movement_speed : float
var have_enterd_screen_once := false
var target : Lighthouse
var flipped_sprite := false

signal ghost_boat_died(score:int)

func _physics_process(delta: float) -> void:
	var  offset : Vector2 
	if flee :
		offset = -light_house_direction * movement_speed * delta
	else :
		offset = light_house_direction * movement_speed * delta	
	global_translate(offset)
	if(!target || life <= 0):
		return
	if target.light.isStopped && Darkness.is_in_light(global_position, collider):
		on_light_overlapp(1)
	elif indicator.visible:
		indicator.visible = false

func _ready() -> void:
	collider.area_entered.connect(area_entered)
	visibleNotifier.screen_exited.connect(screen_exited)
	visibleNotifier.screen_entered.connect(screen_enterd)
	slow_movement_timer.timeout.connect(on_set_back_normal_speed)
	movement_speed = outside_screen_speed
	
func set_target(t:Lighthouse) ->void:
	target = t 
	light_house_direction = (t.global_position - global_position).normalized()
	flipped_sprite =  target.global_position.x > global_position.x
	animatedSprite.flip_h = flipped_sprite
	animatedSprite.play("default")
	#if  spawn_sfx != null and !spawn_sfx.is_empty():
		#var audioStream := spawn_sfx.pick_random() as AudioStream
		#AudioManager.play_sfx(audioStream,-5)
	
func on_set_back_normal_speed() -> void :
	movement_speed = normal_movement_speed
	animatedSprite.play("default",1)

func screen_enterd()-> void :
	have_enterd_screen_once = true
	movement_speed = normal_movement_speed

func screen_exited()-> void :
	if  have_enterd_screen_once:
		queue_free()
	
func area_entered (collision:Area2D) -> void:
	var parent = collision.get_parent()
	if parent is Lighthouse:
		var light_house = parent as Lighthouse
		if (!light_house.game_over):
			light_house.game_over = true
			light_house.on_game_over.emit() 
			if game_over_sfx != null and !game_over_sfx.is_empty():
				var audioStream := game_over_sfx.pick_random() as AudioStream
				var random_pitch := randf_range(min_pitch,max_pitch)
				AudioManager.play_sfx(audioStream,-5,random_pitch)
		set_physics_process(false)
 
func on_light_overlapp(damage : float) -> void:
	if flee:
		return
	life -= damage
	indicator.visible = true
	
	if life <= 0:
		ghost_boat_died.emit(1)
		flee = true
		indicator.visible = false
		animatedSprite.flip_h = !flipped_sprite
		movement_speed = flee_movement_speed
		slow_movement_timer.stop()
		if flee_sfx != null and !flee_sfx.is_empty():
			var audioStream : AudioStream 
			audioStream= flee_sfx.pick_random() as AudioStream
			var random_pitch = randf_range(min_pitch,max_pitch)
			AudioManager.play_sfx(audioStream,-5,random_pitch)
		AudioManager.play_sfx(run_sfx, -5)
		animatedSprite.play("default",2)
	else :
		movement_speed = slow_movement_speed
		if	!slow_movement_timer.is_stopped() :
			slow_movement_timer.stop()
		animatedSprite.play("default",0)
		slow_movement_timer.start(slow_movement_time)
	#print(life)
		
func on_game_over () -> void:
	pass
		
