extends Node2D

class_name  GhostBoat

@export var collider : Area2D
@export var animatedSprite: AnimatedSprite2D
@export var visibleNotifier : VisibleOnScreenNotifier2D
@export var slow_movement_timer : Timer 
@export var life : float
@export var normal_movement_speed: float
@export var slow_movement_speed:float
@export var slow_movement_time : float
var light_house_direction := Vector2(0,0)
var flee := false
var movement_speed : float
var have_enterd_screen_once := false
var target : Lighthouse

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
	if target.light.isStopped && Darkness.is_in_light(global_position):
		on_light_overlapp(1)

func _ready() -> void:
	collider.area_entered.connect(area_entered)
	visibleNotifier.screen_exited.connect(screen_exited)
	visibleNotifier.screen_entered.connect(screen_enterd)
	slow_movement_timer.timeout.connect(on_set_back_normal_speed)
	movement_speed = normal_movement_speed
	
func set_target(t:Lighthouse) ->void:
	target = t 
	print(target)
	light_house_direction = (t.global_position - global_position).normalized()

func on_set_back_normal_speed() -> void :
	movement_speed = normal_movement_speed

func screen_enterd()-> void :
	have_enterd_screen_once = true

func screen_exited()-> void :
	if have_enterd_screen_once:
		#remove boat and add score
		queue_free()
	
	
func area_entered (collision:Area2D) -> void:
	var owner =	collision.get_shape_owners()
	  
func on_light_overlapp(damage : float) -> void:
	life -= damage
	if life <= 0:
		flee = true
		movement_speed = normal_movement_speed
		slow_movement_timer.stop()
	else :
		movement_speed = slow_movement_speed
		if	!slow_movement_timer.is_stopped() :
			slow_movement_timer.stop()
		slow_movement_timer.start(slow_movement_time)
	print(life)
		
		
