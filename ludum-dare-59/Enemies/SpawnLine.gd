extends Node2D
class_name SpawnLine


@export var spawn_position : Node2D 
@export var path_follow: PathFollow2D

func set_progress_ratio(progress:float) ->void:
	path_follow.progress_ratio = progress
	
	
func get_spawn_global_position() -> Vector2:
	return spawn_position.global_position
