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
@export var flee_movement_speed: float
@export var slow_movement_speed:float
@export var slow_movement_time : float

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
	movement_speed = normal_movement_speed
	
func set_target(t:Lighthouse) ->void:
	target = t 
	print(target)
	light_house_direction = (t.global_position - global_position).normalized()
	flipped_sprite =  target.global_position.x > global_position.x
	animatedSprite.flip_h = flipped_sprite
	animatedSprite.play("default")
	
func on_set_back_normal_speed() -> void :
	movement_speed = normal_movement_speed

func screen_enterd()-> void :
	have_enterd_screen_once = true

func screen_exited()-> void :
	if have_enterd_screen_once:
		#remove boat and add score
		queue_free()
	
func area_entered (collision:Area2D) -> void:
	var parent = collision.get_parent()
	if parent is Lighthouse:
		var light_house = parent as Lighthouse
		if (!light_house.game_over):
			light_house.game_over = true
			light_house.on_game_over.emit() 
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
	else :
		movement_speed = slow_movement_speed
		if	!slow_movement_timer.is_stopped() :
			slow_movement_timer.stop()
		slow_movement_timer.start(slow_movement_time)
	#print(life)
		
func on_game_over () -> void:
	pass
		
