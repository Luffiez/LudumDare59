extends Control
class_name  GameUI
@export var screen_center: RichTextLabel
@export var game_over_text : RichTextLabel
@export var scoreButton : Button
@export var light_house : Lighthouse
var score:=0

func _ready() -> void:
	scoreButton.text = str(score)
	light_house.on_game_over.connect(on_game_over)

	
func gain_score(score:int)->void:
	score += score
	scoreButton.text = str(score)


	
func on_game_over()->void:
	var tween := create_tween()
	tween.tween_property(game_over_text, "position",screen_center.position, 3.0)
	var jump_up_position = Vector2(screen_center.position.x, screen_center.position.y -100) 
	tween.tween_property(game_over_text, "position",jump_up_position, 0.5)
	tween.tween_property(game_over_text, "position",screen_center.position, 0.5)
	
 
