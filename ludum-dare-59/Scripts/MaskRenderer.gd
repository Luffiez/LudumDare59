extends Node2D

var revealers: Array = []
var viewport_size: Vector2 = Vector2(512, 512)

func _get_main_viewport() -> Viewport:
	return get_tree().root

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

func _draw():
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0, 0, 0))

	for r in revealers:
		if not is_instance_valid(r.node):
			continue
		var pos = _world_to_mask(r.node.global_position)
		match r.shape:
			DarknessManager.Shape.CIRCLE:
				draw_circle(pos, _scale_to_mask(r.size), Color(1, 1, 1))
			DarknessManager.Shape.RECT:
				var scaled = _scale_to_mask(r.size.length())
				draw_rect(Rect2(pos - Vector2(scaled, scaled), Vector2(scaled, scaled) * 2), Color(1, 1, 1))
			DarknessManager.Shape.CONE:
				_draw_cone_mask(pos, r.size.length, r.size.angle, r.node.global_rotation, r.size.get("start_radius", 0.0))

func _draw_cone_mask(pos: Vector2, length: float, cone_angle: float, direction: float, start_radius: float = 0.0):
	var scaled_length = _scale_to_mask(length)
	var scaled_start = _scale_to_mask(start_radius)
	var steps = 24
	var points: Array = []

	# Start arc (inner edge)
	for i in range(steps + 1):
		var angle = direction - cone_angle / 2.0 + (cone_angle / steps) * i
		points.append(pos + Vector2(cos(angle), sin(angle)) * scaled_start)

	# End arc (outer edge) — reversed so polygon winds correctly
	for i in range(steps, -1, -1):
		var angle = direction - cone_angle / 2.0 + (cone_angle / steps) * i
		points.append(pos + Vector2(cos(angle), sin(angle)) * scaled_length)

	draw_polygon(points, [Color(1, 1, 1)])
