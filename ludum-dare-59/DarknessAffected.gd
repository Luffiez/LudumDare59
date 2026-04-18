extends Node2D  # or Sprite2D, etc.

enum VisibilityType { HIDDEN, WATER }

@export var visibility_type: VisibilityType = VisibilityType.HIDDEN

func _ready():
	var shader_path = "res://hidden_object.gdshader"
	if visibility_type == VisibilityType.WATER:
		shader_path = "res://water.gdshader"

	var mat = ShaderMaterial.new()
	mat.shader = load(shader_path)
	mat.set_shader_parameter("mask_texture", Darkness.mask_texture)
	material = mat
	
func _process(delta):
	if visibility_type == VisibilityType.WATER:
		return
		
	if Darkness.is_in_light(global_position):
		print("I am in the light!")
