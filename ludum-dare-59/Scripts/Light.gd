# Lighthouse.gd
class_name Light
extends Node2D

@export var cone_length: float = 300.0
@export var cone_angle: float = 0.3  # radians (~17 degrees)
@export var rotation_speed: float = 0.8  # radians per second
@export var rotation_speed_boosted: float = 0.8  # radians per second

var isStopped : bool

func _ready():
	var size = get_viewport().get_visible_rect().size
	var center = Vector2(size.x / 2, size.y /2)
	get_parent().global_position = center
	
	Darkness.register_revealer(self, DarknessManager.Shape.CONE, {
		"length": cone_length,
		"angle": cone_angle,
		"start_radius": 5
	})

func _process(delta):
	isStopped = Input.is_action_pressed("stop")
	if(isStopped):
		return
	
	# Darkness reads rotation automatically
	if(Input.is_action_pressed("speed")):
		rotation += rotation_speed_boosted * delta  
	else:
		rotation += rotation_speed * delta  

func _exit_tree():
	Darkness.unregister_revealer(self)
