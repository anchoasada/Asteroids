extends Control
class_name HighscoreScreen

@onready var highscores_container = $HighscoresContainer

func _ready():
	update_screen()

func update_screen() -> void:
	var _container_size: int = highscores_container.get_child_count()
	
	for i in range(Highscore.highscores.size()):
		var container: UserHighscoreContainer = highscores_container.get_child(i)
		var highscore: Array = Highscore.highscores[i]
		
		container.username = highscore[0]
		container.points = highscore[1]
		container.update_labels()

func clean_highscores() -> void:
	for container: UserHighscoreContainer in highscores_container.get_children():
		container.username = "AAA"
		container.points = 0
		container.update_labels()

func _on_return_button_pressed():
	hide()


func _on_reset_hs_button_pressed():
	hide()
	Highscore.delete_highscores()
	clean_highscores()
	
