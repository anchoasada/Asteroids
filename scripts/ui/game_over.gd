extends Control
class_name GameOverScreen

@onready var animation_player := $AnimationPlayer
@onready var new_game_button := $NewGameButton
@onready var submit_score = $SubmitScore

func _ready():
	self.hide()
	submit_score.global_position = Vector2.ZERO
	submit_score.hide()
	new_game_button.disabled = true
	new_game_button.hide()
	Global.no_lives_left.connect(_on_no_lives_left)

func _on_no_lives_left():
	self.show()
	animation_player.play("screen_spawn")

func _on_new_game_button_pressed():
	if Highscore.check_score(Global.points):
		submit_score.process_mode = Node.PROCESS_MODE_INHERIT
		submit_score.points = Global.points
		submit_score.show()
	else:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
