extends Node

const SAVE_SCORE_PATH := "user://highscores"
const MAX_HIGHSCORE_SIZE: int = 10

## Contains an [Array] of the top 10 highscores. The scores are sorted and each one
## is an [Array], being the first member the username and the second one the score.
var highscores: Array

func _ready():
	load_highscores()

func save_highscores_file() -> void:
	var file = FileAccess.open(SAVE_SCORE_PATH, FileAccess.WRITE_READ)
	file.store_var(highscores)
	file.close()
	print("Highscores saved sucesfully!!")

func load_highscores() -> void:
	var file = FileAccess.open(SAVE_SCORE_PATH, FileAccess.READ)
	if file != null:
		highscores = file.get_var()
		sort_hightable()
		
		print("Highscores:\n")
		for i in range(highscores.size()):
			print(highscores[i])

func delete_highscores() -> void:
	highscores = []
	DirAccess.remove_absolute(SAVE_SCORE_PATH)
	print("Highscores deleted sucesfully!")
	
func check_score(score: int) -> bool:
	if highscores.size() < MAX_HIGHSCORE_SIZE:
		print("There's space for more scores.")
		return true
	
	var score_valid: bool = false
	
	for user_data in highscores:
		var user_score = user_data[1]
		if score >= user_score:
			score_valid = true
			print("The score is valid.")
			break
	
	if !score_valid:
		print("The score is not high enough.")
	
	return score_valid

func insert_new_score(user: String, score: int) -> void:
	
	var player_data: Array = [user, score]
	print("\nSaving update: Loaded data -> " + str(player_data))
	
	highscores.append(player_data)
	sort_hightable()
	
	if highscores.size() > 10:
		highscores.pop_back()
	
	Global.print_important_message("New score inserted sucesfully!!")
	save_highscores_file()
	return

func sort_hightable() -> void:
	highscores.sort_custom(_sort_highscores)
	Global.print_important_message("Highscores sorted!!!")
	return

func _sort_highscores(a: Array, b: Array) -> bool:
	if a[1] > b[1]:
		return true
	if a[1] == b[1]:
		return a[0] < b[0]
	return false
