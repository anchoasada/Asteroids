extends HBoxContainer
class_name UserHighscoreContainer

@export var position_in_highscore: int
@export var username: String
@export var points: int

@onready var position_label = $UserContainer/PositionLabel
@onready var username_label = $UserContainer/UsernameLabel
@onready var points_label = $PointsLabel

func _ready():
	update_labels()

func update_labels() -> void:
	position_label.text = str(position_in_highscore) + "."
	username_label.text = username
	points_label.text = str(points)
