# Lighthouse.gd
class_name Lighthouse
extends Node2D

@export var light: Light
@export var anim: AnimatedSprite2D

signal on_game_over()

var game_over:= false

func _ready() -> void:
	anim.play("idle")
