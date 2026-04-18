extends ColorRect

const MAP_SIZE = Vector2i(256, 256)

enum Shape { CIRCLE, RECT, CONE }

var image: Image
var texture: ImageTexture
var revealers: Array = []
var mask_texture: ImageTexture  # publicly accessible

func _ready():
	var shader = load("res://Shaders/darkness.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material = shader_material

	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 0
	offset_bottom = 0

	image = Image.create(MAP_SIZE.x, MAP_SIZE.y, false, Image.FORMAT_L8)
	mask_texture = ImageTexture.create_from_image(image)
	material.set_shader_parameter("mask_texture", mask_texture)
	visible = false

func register_revealer(node: Node, shape: Shape, size):
	revealers.append({"node": node, "shape": shape, "size": size})

func unregister_revealer(node: Node):
	revealers = revealers.filter(func(r): return r.node != node)

func _process(_delta):
	image.fill(Color(0, 0, 0))
	for r in revealers:
		if is_instance_valid(r.node):
			match r.shape:
				Shape.CIRCLE:
					reveal_circle(r.node.global_position, r.size)
				Shape.RECT:
					reveal_rect(r.node.global_position, r.size)
				Shape.CONE:
					reveal_cone(
						r.node.global_position,
						r.size.length,
						r.size.angle,
						r.node.rotation  # uses the node's own rotation
					)
	mask_texture.update(image)

func _world_to_pixel(world_pos: Vector2) -> Vector2i:
	var map_rect = get_viewport_rect()
	var uv = world_pos / map_rect.size
	return Vector2i(uv * Vector2(MAP_SIZE))

func reveal_circle(world_pos: Vector2, radius: float):
	var map_rect = get_viewport_rect()
	var center = _world_to_pixel(world_pos)
	var pixel_radius = int(radius / map_rect.size.x * MAP_SIZE.x)

	for x in range(center.x - pixel_radius, center.x + pixel_radius):
		for y in range(center.y - pixel_radius, center.y + pixel_radius):
			if x < 0 or y < 0 or x >= MAP_SIZE.x or y >= MAP_SIZE.y:
				continue
			if Vector2i(x, y).distance_to(center) <= pixel_radius:
				image.set_pixel(x, y, Color(1, 1, 1))

func reveal_rect(world_pos: Vector2, half_extents: Vector2):
	var map_rect = get_viewport_rect()
	var center = _world_to_pixel(world_pos)
	var pixel_half = Vector2i(
		int(half_extents.x / map_rect.size.x * MAP_SIZE.x),
		int(half_extents.y / map_rect.size.y * MAP_SIZE.y)
	)

	for x in range(center.x - pixel_half.x, center.x + pixel_half.x):
		for y in range(center.y - pixel_half.y, center.y + pixel_half.y):
			if x < 0 or y < 0 or x >= MAP_SIZE.x or y >= MAP_SIZE.y:
				continue
			image.set_pixel(x, y, Color(1, 1, 1))

func reveal_cone(world_pos: Vector2, length: float, cone_angle: float, direction: float):
	var map_rect = get_viewport_rect()
	var center = _world_to_pixel(world_pos)
	var pixel_length = int(length / map_rect.size.x * MAP_SIZE.x)
	var half_angle = cone_angle / 2.0

	for x in range(center.x - pixel_length, center.x + pixel_length):
		for y in range(center.y - pixel_length, center.y + pixel_length):
			if x < 0 or y < 0 or x >= MAP_SIZE.x or y >= MAP_SIZE.y:
				continue
			var offset = Vector2(x - center.x, y - center.y)
			if offset.length() > pixel_length:
				continue
			# Get the angle of this pixel relative to the cone direction
			var pixel_angle = offset.angle()
			var angle_diff = abs(wrapf(pixel_angle - direction, -PI, PI))
			if angle_diff <= half_angle:
				image.set_pixel(x, y, Color(1, 1, 1))

func is_in_light(world_pos: Vector2) -> bool:
	var pixel = _world_to_pixel(world_pos)
	if pixel.x < 0 or pixel.y < 0 or pixel.x >= MAP_SIZE.x or pixel.y >= MAP_SIZE.y:
		return false
	return image.get_pixel(pixel.x, pixel.y).r > 0.5
