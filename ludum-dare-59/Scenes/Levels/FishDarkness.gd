extends AnimatedSprite2D

var _mat: ShaderMaterial

func _ready():
	await RenderingServer.frame_post_draw

	_mat = ShaderMaterial.new()
	_mat.shader = load("res://Shaders/Water.gdshader")
	material = _mat

func _process(_delta):
	if _mat and Darkness.mask_texture:
		_mat.set_shader_parameter("mask_texture", Darkness.mask_texture)
