extends Node
class_name DarknessManager

enum Shape { CIRCLE, RECT, CONE }

var revealers: Array = []
var mask_texture: ViewportTexture
var mask_renderer: Node2D

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
				var to_point = world_pos - r.node.global_position
				if to_point.length() <= r.size.length:
					var angle_diff = abs(wrapf(to_point.angle() - r.node.rotation, -PI, PI))
					if angle_diff <= r.size.angle / 2.0:
						return true
	return false
