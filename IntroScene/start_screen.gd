@icon("res://addons/IntroScene/You are watching a master of work.jpeg")
extends Control
class_name IntroScene

@export var next_scene: PackedScene

@onready var animation_player = $AnimationPlayer
@onready var moai_label = $MoaiLabel
@onready var text_label = $TextLabel

func _input(event):
	if event is InputEventMouseButton or event is InputEventKey:
		change_scene()

func change_scene() -> void:
	animation_player.stop()
	moai_label.hide()
	text_label.hide()
	await get_tree().create_timer(0.4).timeout
	
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
	else:
		assert(false, "No scene was loaded to be the next scene.\n"
		+ "Please, introduce a scene inside the 'next_scene' property.")

func _on_animation_finished(_anim_name):
	change_scene()
