@icon("res://assets/icons/asteroid_icon.svg")
extends Area2D
class_name Asteroid

## Class that represents an Asteroid. 
##
## Once has spawned, it will go in a straight line, pointing at the direction
## defined by the [member asteroid_direction] property. If it collides with the
## spaceship, it will make it lose a life.
## [br][br]
## Howewer, if the [Asteoid] collides with a [Bullet], it will be destroyed, calling
## the [method destroy] function and spliting into smaller asteroids, until a point
## where it won't split into more asteroids and just dissapear.

const ASTEROID_TYPE_1 := preload("res://scenes/asteroid_type_1.tscn")
const ASTEROID_TYPE_2 := preload("res://scenes/asteroid_type_2.tscn")
const ASTEROID_TYPE_3 := preload("res://scenes/asteroid_type_3.tscn")

## The points earned when destroying a asteroid of tier 1.
static var tier_1_points: int = 20
## The points earned when destroying a asteroid of tier 2.
static var tier_2_points: int = 50
## The points earned when destroying a asteroid of tier 3.
static var tier_3_points: int = 100

var asteroid_speed: float ## Asteroid speed. Ideally, it should be from 100 to 200.
var asteroid_tier: int ## Tier of the asteoid, being 1 the biggest and 3 the lowest.
var asteroid_direction: float ## Asteroid movement direction.
var asteroid_rotation_speed: float ## Asteroid self rotation speed.

## Set to [code]true[/code] when the asteroid collides with a [Bullet], to prevent
## certain methods to be called.
var is_destroyed: bool = false 

var limit_margin: Vector2i

var up_limit: float
var down_limit: float
var left_limit: float
var right_limit: float

@onready var destroy_particles = $DestroyParticles
@onready var sprite = $AnimatedSprite2D

@onready var big_explosion_sound = $BigExplosionSound
@onready var medium_explosion_sound = $MediumExplosionSound
@onready var small_explosion_sound = $SmallExplosionSound

static func create_asteroids(amount: int) -> Array[Asteroid]:
	var asteroids_created: Array[Asteroid] = []
	
	for i in range(amount):
		var asteroid: Asteroid 
		var type_asteroid: int = randi_range(1, 3)
		
		match type_asteroid:
			1:
				asteroid = ASTEROID_TYPE_1.instantiate()
			2:
				asteroid = ASTEROID_TYPE_2.instantiate()
			3:
				asteroid = ASTEROID_TYPE_3.instantiate()
		
		asteroids_created.append(asteroid)
	
	return asteroids_created 

func _ready():
	global_rotation = randf_range(0, PI * 2)
	asteroid_rotation_speed = randf_range(0.001, 0.01)
	
	match asteroid_tier:
		1:
			modulate.a = 1
			scale = Vector2i.ONE
		2: 
			modulate.a = 0.7
			scale = Vector2(0.7, 0.7)
		3: 
			modulate.a = 0.5
			scale = Vector2(0.4, 0.4)
	
	## Defines the margin between the edges of the screen and the limits of the game.
	limit_margin = Vector2(50, 50) * self.scale

	left_limit = 0 - limit_margin.x ## Position of the left limit (X Axis)
	right_limit = Global.SCREEN_SIZE.x + limit_margin.x ## Position of the right limit (X Axis)
	up_limit = 0 - limit_margin.y ## Position of the up limit (Y Axis)
	down_limit = Global.SCREEN_SIZE.y + limit_margin.x ## Position of the down limit (Y Axis)
	

func _physics_process(delta): 
	_move_asteroid(delta)

## Called when collides with the spaceship or a bullet. First, it will call 
## the [method split_asteroid] function to spawn smaller asteroids. The amount
## of asteroids created depends of the current [member asteroid_tier]:
## [br][br]
## Tier 1: It will split into [b]3[/b] Tier 2 asteroids.[br]
## Tier 2: It will split into [b]2[/b] Tier 3 asteroids.[br]
## Tier 3: It will split into [b]0[/b] asteroids.[br]
## [br]
## After that and before eliminating the asteroid, it will call the functions
## [method Global.add_points] and [method Global.asteroid_destroyed] to give 
## the player a certain amount of points (determined with the constant
## [constant ASTEROID_POINTS_VALUE] and also substract 1 from the 
## [member Global.asteroids_in_screen] count.
func destroy() -> void:
	var asteroid_points = 0
	is_destroyed  = true
	destroy_particles.emitting = true
	
	
	match asteroid_tier:
		1:
			split_asteroid(2)
			big_explosion_sound.play()
			asteroid_points = tier_1_points
		2:
			split_asteroid(2)
			medium_explosion_sound.play()
			asteroid_points = tier_2_points
		3:
			small_explosion_sound.play()
			asteroid_points = tier_3_points
	
	sprite.hide()
	Global.add_points(asteroid_points)
	Global.call_deferred("asteroid_destroyed")
	await destroy_particles.finished
	queue_free()

## Function called when a asteroid is destroyed. It will spawn an amount of asteroids,
## depending of the given [param amount] parameter. 
## [br]
## The new asteroids spawned with this function will have the next changes:
## [br][br]
## - First, his [member asteroid_tier] will be increased by [b]1[/b].[br]
## - His [member global_position] will be the same where the parent asteroid was
## destroyed.[br]
## - The new asteroids will receive a speed multiplier. The smaller the asteroid is.
## more chances has to receive a higher multiplier.
func split_asteroid(amount: int) -> void:
	var new_asteroids: Array[Asteroid] = Asteroid.create_asteroids(amount)
	
	for asteroid in new_asteroids:
	
		asteroid.global_position = self.global_position
		asteroid.asteroid_tier = self.asteroid_tier + 1
		
		var speed_multiplier: float
		match asteroid.asteroid_tier:
			2: 
				speed_multiplier = randf_range(1.1, 1.75)
			3: 
				speed_multiplier = randf_range(1.1, 2.0)
		
		asteroid.asteroid_speed = self.asteroid_speed * speed_multiplier
		asteroid.asteroid_direction = randf_range(0, PI * 2)
	
		Global.asteroid_created()
		get_parent().call_deferred("add_child", asteroid)

func _move_asteroid(delta: float) -> void:
	var speed: Vector2 = asteroid_speed * Vector2.from_angle(asteroid_direction) * delta
	rotate(asteroid_rotation_speed)
	
	global_position += speed * Global.global_speed
	
	if global_position.y < up_limit:
		global_position.y = down_limit
	elif global_position.y > down_limit:
		global_position.y = up_limit
	
	if global_position.x < left_limit:
		global_position.x = right_limit
	elif global_position.x > right_limit:
		global_position.x = left_limit


func _on_body_entered(body) -> void:
	if body.is_in_group("player") and !is_destroyed and !body.is_invulnerable():
		self.destroy()
		body.kill()

func _on_area_entered(area):
	if area.is_in_group("alien"):
		self.destroy()
		area.kill()
