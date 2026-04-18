# Lighthouse.gd
extends Node2D

@export var cone_length: float = 300.0
@export var cone_angle: float = 0.3  # radians (~17 degrees), adjust to taste
@export var rotation_speed: float = 0.8  # radians per second

func _ready():
	Darkness.register_revealer(self, Darkness.Shape.CONE, {
		"length": cone_length,
		"angle": cone_angle
	})

func _process(delta):
	if(Input.is_action_pressed("stop")):
		TryAttack()
	else:
		rotation += rotation_speed * delta  # Darkness reads this automatically

func _exit_tree():
	Darkness.unregister_revealer(self)


func TryAttack():
	pass
