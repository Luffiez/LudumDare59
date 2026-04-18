extends Node

signal scene_changed(scene_path)

var current_scene: Node
var current_scene_path: String

func _ready():
	current_scene = get_tree().current_scene
	if current_scene:
		current_scene_path = current_scene.scene_file_path

func change_scene(scene_path: String):
	current_scene_path = scene_path
	get_tree().change_scene_to_file(scene_path)
	scene_changed.emit(scene_path)

func reload_scene():
	if current_scene_path != "":
		change_scene(current_scene_path)

func quit_game():
	get_tree().quit()

func change_scene_async(scene_path: String):
	current_scene_path = scene_path
	
	var resource = await ResourceLoader.load_threaded_request(scene_path)
	var packed_scene = ResourceLoader.load_threaded_get(scene_path)
	
	get_tree().change_scene_to_packed(packed_scene)
	scene_changed.emit(scene_path)
