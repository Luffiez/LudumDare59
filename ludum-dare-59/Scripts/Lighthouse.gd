# Lighthouse.gd
extends Node2D

class_name Lighthouse

@export var cone_length: float = 300.0
@export var cone_angle: float = 0.3  # radians (~17 degrees)
@export var rotation_speed: float = 0.8  # radians per second
@export var rotation_speed_boosted: float = 0.8  # radians per second

func _ready():
	Darkness.register_revealer(self, DarknessManager.Shape.CONE, {
		"length": cone_length,
		"angle": cone_angle,
		"start_radius": 15
	})
func _process(delta):
	if(Input.is_action_pressed("stop")):
		return
	
	# Darkness reads rotation automatically
	if(Input.is_action_pressed("speed")):
		rotation += rotation_speed_boosted * delta  
	else:
		rotation += rotation_speed * delta  

func _exit_tree():
	Darkness.unregister_revealer(self)
