extends Control
class_name UI

@onready var lives_container = $LivesContainer
@onready var points_label = $PointsLabel

func _ready():
	points_label.text = str(Global.points)
	
	Global.live_lost.connect(_on_live_lost)
	Global.live_added.connect(_on_live_added)
	Global.update_points.connect(_on_update_points)
	Global.no_lives_left.connect(_on_no_lives_left)

func _on_live_lost():
	if lives_container.get_child_count() != 0:
		var live_icon = lives_container.get_child(lives_container.get_child_count() - 1)
		live_icon.queue_free()

func _on_live_added():
	var live_icon = lives_container.get_child(0).duplicate()
	lives_container.add_child(live_icon)

func _on_update_points():
	points_label.text = str(Global.points)

func _on_no_lives_left():
	hide()
