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

func is_in_light(world_pos: Vector2, my_collision_shape : Area2D) -> bool:
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
				if _is_shape_in_cone(r, my_collision_shape):
					return true
				#var origin = _world_to_mask(r.node.global_position)
				#var test_point = _world_to_mask(world_pos)
				#var to_point = test_point - origin
				#if to_point.length() <= _scale_to_mask(r.size.length):
					#var direction = r.node.global_rotation
					#var adjusted_angle = _get_adjusted_angle(r.size.angle, direction)
					#var forward = Vector2(cos(direction), sin(direction))
					#if forward.dot(to_point.normalized()) >= cos(adjusted_angle / 2.0):
						#return true
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


func _is_shape_in_cone(r, area: Area2D) -> bool:
	var origin = _world_to_mask(r.node.global_position)
	var direction = r.node.global_rotation
	var adjusted_angle = _get_adjusted_angle(r.size.angle, direction)
	var forward = Vector2(cos(direction), sin(direction))
	var max_dist = _scale_to_mask(r.size.length)

	for world_pt in _get_shape_test_points(area):
		var to_point = _world_to_mask(world_pt) - origin
		if to_point.length() <= max_dist:
			if to_point.is_zero_approx() or forward.dot(to_point.normalized()) >= cos(adjusted_angle / 2.0):
				return true

	return false


func _get_shape_test_points(area: Area2D) -> Array:
	var points = []

	for child in area.get_children():
		if child is CollisionShape2D and child.shape:
			var shape = child.shape
			var transform = child.global_transform

			if shape is CircleShape2D:
				points.append(transform.origin)
				var r = shape.radius
				for i in range(8):
					var a = i * TAU / 8.0
					points.append(transform * (Vector2(cos(a), sin(a)) * r))  # ✅

			elif shape is RectangleShape2D:
				var e = shape.size / 2.0
				points.append(transform.origin)
				points.append(transform * Vector2( e.x,  e.y))
				points.append(transform * Vector2(-e.x,  e.y))
				points.append(transform * Vector2( e.x, -e.y))
				points.append(transform * Vector2(-e.x, -e.y))

			elif shape is CapsuleShape2D:
				points.append(transform.origin)
				var r = shape.radius
				var h = shape.height / 2.0 - r
				for cap in [Vector2(0, -h), Vector2(0, h)]:
					for i in range(6):
						var a = i * TAU / 6.0
						points.append(transform * (cap + Vector2(cos(a), sin(a)) * r))

			else:
				points.append(transform.origin)

	return points
