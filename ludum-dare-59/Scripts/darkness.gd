extends Node
class_name DarknessManager

enum Shape { CIRCLE, RECT, CONE }

var revealers: Array = []
var mask_texture: ViewportTexture
var mask_renderer: Node2D
var viewport_size: Vector2 = Vector2(512, 512)


func _ready():
	var subviewport = $SubViewport
	subviewport.transparent_bg = false
	RenderingServer.viewport_set_clear_mode(
		subviewport.get_viewport_rid(),
		RenderingServer.VIEWPORT_CLEAR_ALWAYS
	)
	
	mask_renderer = $SubViewport/MaskRenderer
	mask_texture = subviewport.get_texture()

func register_revealer(node: Node, shape: Shape, size):
	revealers.append({"node": node, "shape": shape, "size": size})
	mask_renderer.revealers = revealers

func unregister_revealer(node: Node):
	revealers = revealers.filter(func(r): return r.node != node)
	mask_renderer.revealers = revealers

func _process(_delta):
	mask_renderer.queue_redraw()  # triggers _draw() on the GPU every frame

func is_in_light(world_pos: Vector2) -> bool:
	for r in revealers:
		if not is_instance_valid(r.node):
			continue
		match r.shape:
			Shape.CIRCLE:
				if r.node.global_position.distance_to(world_pos) <= r.size:
					return true
			Shape.RECT:
				var rect = Rect2(r.node.global_position - r.size, r.size * 2)
				if rect.has_point(world_pos):
					return true
			Shape.CONE:
				var origin = _world_to_mask(r.node.global_position)
				var test_point = _world_to_mask(world_pos)
				var to_point = test_point - origin
				if to_point.length() <= _scale_to_mask(r.size.length):
					var direction = r.node.global_rotation
					var adjusted_angle = _get_adjusted_angle(r.size.angle, direction)
					var forward = Vector2(cos(direction), sin(direction))
					if forward.dot(to_point.normalized()) >= cos(adjusted_angle / 2.0):
						return true
	return false
	
func _get_adjusted_angle(cone_angle: float, direction: float) -> float:
	var vertical_factor = abs(sin(direction))
	return lerp(cone_angle, cone_angle * 0.6, vertical_factor)
	
func _world_to_mask(world_pos: Vector2) -> Vector2:
	var main_vp = _get_main_viewport()
	var camera = main_vp.get_camera_2d()
	var screen_size = main_vp.get_visible_rect().size
	var screen_pos: Vector2
	if camera:
		screen_pos = world_pos - camera.global_position + screen_size / 2.0
	else:
		screen_pos = world_pos
	return (screen_pos / screen_size) * viewport_size

func _scale_to_mask(world_length: float) -> float:
	var screen_size = _get_main_viewport().get_visible_rect().size
	return world_length / screen_size.x * viewport_size.x

func _get_main_viewport() -> Viewport:
	return get_tree().root
