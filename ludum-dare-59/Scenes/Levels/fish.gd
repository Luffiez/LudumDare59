extends Node2D

@export var sprite : AnimatedSprite2D

@export var min_timer : float = 15
@export var max_timer : float = 90

var timer : float 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_time()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if(timer <= 0):
		randomize_time()
		sprite.play("active")
		print("FISHY")
		
func randomize_time() -> void:
	timer = randf_range(min_timer, max_timer)
