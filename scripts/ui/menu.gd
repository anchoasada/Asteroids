extends Node
class_name Menu

@onready var highscores_screen = $HighscoresScreen

func _ready():
	highscores_screen.global_position = Vector2.ZERO
	highscores_screen.hide()
	generate_asteroids(10)

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().quit()

func generate_asteroids(amount: int) -> void:
	var new_asteroids = Asteroid.create_asteroids(amount)
	for asteroid in new_asteroids:
		
		var margin = 100
		match randi_range(0, 3):
			0: # Up
				asteroid.global_position = Vector2(
					randi_range(0, Global.SCREEN_SIZE.x), 
					randi_range(0, margin)
				)
			1: # Down
				asteroid.global_position = Vector2(
					randi_range(0, Global.SCREEN_SIZE.x), 
					randi_range(Global.SCREEN_SIZE.y - margin, Global.SCREEN_SIZE.y)
				)
			2: # Right
				asteroid.global_position = Vector2(
					randi_range(Global.SCREEN_SIZE.x - margin, Global.SCREEN_SIZE.x), 
					randi_range(0, Global.SCREEN_SIZE.y)
				)
			3: # Left
				asteroid.global_position = Vector2(
					randi_range(0, margin), 
					randi_range(0, Global.SCREEN_SIZE.y)
				)
				
		asteroid.asteroid_speed = randf_range(40, 75)
		var tier_selected: int = randi_range(1, 3)
		asteroid.asteroid_tier = tier_selected
		asteroid.asteroid_direction = randf_range(0, PI * 2)
		add_child(asteroid)

func _on_new_game_button_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_highscores_button_pressed():
	highscores_screen.update_screen()
	highscores_screen.show()
