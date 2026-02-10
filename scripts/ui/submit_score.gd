extends Control
class_name SubmitScoreScreen

signal score_submitted

@export var points: int
var username_submitted: String

@onready var points_amount_label = $PointsContainer/PointsAmount
@onready var confirm_warning_label = $ConfirmWarningLabel
@onready var enter_score_input = $ScoreInputContainer/EnterScoreInput
@onready var animation_player = $AnimationPlayer

func _ready():
	points_amount_label.text = str(points)
	process_mode = Node.PROCESS_MODE_DISABLED

func _input(event):
	if event.is_action_pressed("accept"):
		save_score()

func save_score() -> void:
	username_submitted = enter_score_input.text
	Highscore.insert_new_score(username_submitted, points)
	
	score_submitted.emit()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_visibility_changed():
	points_amount_label.text = str(points)
