extends Node

## Singleton used to store data of the current game.
##
## Stores the data of the current game and emits different signals depending
## of if the player gained or lost a life, when the points are updated, etc...

signal update_points ## Emmited when the points change.
signal live_lost ## Emmited when the player lose a life.
signal live_added ## Emmited when the player gets an extra life.
## Emmited when the player destroys a asteroid and after checking, there are no more 
## asteroids in the game.
signal no_asteroids_in_screen 
signal no_lives_left ## Emmited when the player has no lives left.

# NORMAL MODE SIGNALS #########################################################
signal aliens_enabled


const SCREEN_SIZE: Vector2i = Vector2i(900, 800) ## Stores the screen size.

const POINTS_NEEDED_FOR_EXTRA_LIFE: int = 20000 ## The points needed to get a extra life.

var has_game_ended: bool = false

## Defines the global speed of the game. Thinks like asteroids speed or 
## UFO's spawn speed, shot speed and general speed should be affected by this.
var global_speed: float = 1.0

var spaceship_lives: int = 3 ## The lives the player has.
var rounds: int = 0 ## The number of rounds the player has done.
var points: int = 0 ## The points the player has.

## The actual score needed to get an extra life 
var points_for_next_life: int = POINTS_NEEDED_FOR_EXTRA_LIFE 

var asteroids_in_screen: int = 0 ## The current amount of asteroids in game.

## Gives a default value to all the stats of the player and game configuration.
func restart_game():
	has_game_ended = false
	spaceship_lives = 3
	rounds = 0
	points = 0
	asteroids_in_screen = 0
	print_important_message("Restarting game... Game current stats:\n\n" +
	"Lives: " + str(spaceship_lives) + "\n" +
	"Current Round: " + str(rounds) + "\n" +
	"Current Points: " + str(points) + "\n" +
	"Asteroids in screen: " + str(asteroids_in_screen))

## Adds the given [param points_added] amount. 
## @experimental: This method adds an extra life every 50000 points. This could change so that doesn't happen from this method. 
func add_points(points_added: int) -> void:
	if has_game_ended:
		return
	
	points += points_added
	update_points.emit()
	print("Points update: +" + str(points_added) + " points.")
	
	if points >= points_for_next_life:
		add_life()

## Substracts a life from the [member spaceship_lives] count.
func lose_life() -> void:
	spaceship_lives -= 1
	live_lost.emit()
	print_important_message("Lives update: -1 life. Lives Remaining: " 
	+ str(spaceship_lives) + " lives.")

## Adds a life to the [member spaceship_lives] count.
func add_life() -> void:
	spaceship_lives += 1
	live_added.emit()
	
	points_for_next_life += POINTS_NEEDED_FOR_EXTRA_LIFE
	print_important_message("Lives update: +1 life. Points needed for next one: " 
	+ str(points_for_next_life))

## Increases the [member asteroids_in_screen] value by [b]1[/b].
func asteroid_created() -> void:
	asteroids_in_screen += 1
	print("Asteroids Update: +1 Asteroid (via Created)")

## Decreases the [member asteroids_in_screen] value by [b]1[/b].
func asteroid_destroyed() -> void:
	asteroids_in_screen -= 1
	print("Asteroids Update: -1 Asteroid (via Destroyed)")
	
	if asteroids_in_screen <= 0:
		print_important_message("There's no more Asteroids in Screen. Sending
		'no_asteroids_in_screen' signal")
		no_asteroids_in_screen.emit()

## Adds one to the rounds counter and checks if certains entities can start spawning.
func next_round() -> void:
	rounds += 1
	global_speed = 1 + (0.05 * rounds)
	print_important_message("Round  " + str(rounds))
	
	if rounds >= 2:
		aliens_enabled.emit()

## Returns [code]true[/code] if the spaceship has any live left (checking 
## [member spaceship_lives]). If not, returns [code]false[/code] and emits
## [signal no_lives_left].
func has_spaceship_lives() -> bool:
	if spaceship_lives <= 0:
		no_lives_left.emit()
		return false
	else:
		return true

func print_important_message(text: String) -> void:
	print("\n----------------------------------------------------------------\n")
	print(text)
	print("\n----------------------------------------------------------------\n")
