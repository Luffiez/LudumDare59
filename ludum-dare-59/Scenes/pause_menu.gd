extends VBoxContainer

@export var button_target : RichTextLabel
@export var resume_button : Button
@export var home_button : Button
@export var quit_button : Button
@export_file("*.tscn") var home_scene_path: String

var startPos : Vector2

var paused : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	startPos = global_position
	resume_button.pressed.connect(on_toggle_pause)
	home_button.pressed.connect(on_home)
	quit_button.pressed.connect(on_quit)

func _process(delta : float):
	if Input.is_action_just_released("ui_cancel"):
		on_toggle_pause()

func on_toggle_pause():
	paused = !paused
	get_tree().paused = paused
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	var target = button_target.global_position
	if(!paused):
		target = startPos
	tween.tween_property(self, "position", target, 0.25)

func on_home():
	get_tree().paused = false
	SceneManager.change_scene(home_scene_path)

func on_quit():
	SceneManager.quit_game()
