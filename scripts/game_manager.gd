extends Node
class_name GameManager

@export var MENU_SCENE: PackedScene

@export var MIN_ALIEN_SPAWN_TIME: float = 10.0
@export var MAX_ALIEN_SPAWN_TIME: float = 30.0

@onready var asteroids_container = %Asteroids
@onready var aliens_container = %Aliens
@onready var music_player_1 = %MusicPlayer1
@onready var music_player_2 = %MusicPlayer2

func _ready():
	Global.no_asteroids_in_screen.connect(_on_no_asteroids_in_screen)
	Global.aliens_enabled.connect(_on_enable_aliens, CONNECT_ONE_SHOT)
	Global.restart_game()
	
	await get_tree().create_timer(2.0).timeout
	spawn_asteroids(5)
	play_music()

func _input(event):
	if event.is_action_pressed("exit"):
		get_tree().change_scene_to_packed(MENU_SCENE)


func spawn_asteroids(amount: int) -> void:
	Global.next_round()
	var new_asteroids: Array[Asteroid] = Asteroid.create_asteroids(amount)
	
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
		asteroid.asteroid_tier = 1
		asteroid.asteroid_direction = randf_range(0, PI * 2)
		Global.asteroid_created()
		asteroids_container.add_child(asteroid)

func spawn_alien() -> void:
	var min_alien_spawn_time = MIN_ALIEN_SPAWN_TIME / Global.global_speed
	var max_alien_spawn_time = MAX_ALIEN_SPAWN_TIME / Global.global_speed
	
	var spawn_time: float = randf_range(min_alien_spawn_time, max_alien_spawn_time)
	await get_tree().create_timer(spawn_time).timeout
	
	var new_alien = UFO.create_alien()
	aliens_container.add_child(new_alien)
	spawn_alien()

func play_music() -> void:
	while true:
		music_player_1.play()
		await get_tree().create_timer(1.0).timeout
		music_player_2.play()
		await get_tree().create_timer(1.0).timeout

func _on_no_asteroids_in_screen():
	await get_tree().create_timer(2.0).timeout
	spawn_asteroids(5)

func _on_enable_aliens():
	Global.print_important_message("Round 2 reached. Enabling aliens into the game.")
	spawn_alien()
