extends Control
class_name  GameUI
@export var screen_center: RichTextLabel
@export var game_over_text : RichTextLabel
@export var scoreButton : Button
@export var light_house : Lighthouse
@export var game_over_buttons : VBoxContainer
@export var buttons_end : RichTextLabel
var score:=0

func _ready() -> void:
	scoreButton.text = str(score)
	light_house.on_game_over.connect(on_game_over)

	
func gain_score(score_to_add:int)->void:
	score += score_to_add
	scoreButton.text = str(score)


	
func on_game_over()->void:
	var tween := create_tween()
	tween.tween_property(game_over_text, "position",screen_center.position, 1.0)
	tween.parallel().tween_property(game_over_buttons,"position",buttons_end.position,1.0)
	var jump_up_position = Vector2(screen_center.position.x, screen_center.position.y -50) 
	tween.tween_property(game_over_text, "position",jump_up_position, 0.5)
	tween.tween_property(game_over_text, "position",screen_center.position, 0.5)
	
 
