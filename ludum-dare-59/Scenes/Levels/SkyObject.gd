extends Node2D

@export var pathFollow : PathFollow2D
@export var speed : float = 1
@export var randomizeStart : bool = false

func _ready() -> void:
	if randomizeStart:
		pathFollow.progress_ratio = randf()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var ratio = pathFollow.progress_ratio + delta * speed
	if ratio > 1:
		ratio = 0
	pathFollow.progress_ratio = ratio 
