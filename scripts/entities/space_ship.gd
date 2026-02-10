@icon("res://assets/icons/ship_icon.svg")
extends CharacterBody2D
class_name SpaceShip

## This class represents the spaceship, controlled by the user, whose objective
## is to destroy asteroids to gain the most points as possible.
##
## The spaceship is controlled by the user, using the actions defined in 
## [i]Project > Project Settings > Input Map[/i] to rotate left and right and
## go forward. Also the spaceship can shot [Bullet] using the action "shot" (using 
## [kbd]Space[/kbd] or [kbd]Left Click[/kbd]) to destroy the [Asteroid].
## [br][br]
## If the spaceship touches some other objets like the asteroids, aliens or other
## enemies, it will be destroyed, losing a life in the process.

@export var rotation_speed: float = 4.5 ## The speed which the spaceship rotates.
@export var max_speed: float = 350.0 ## The max speed the spaceship can reach.
@export var acceleration: float = 550.0 ## The acceleration of the spaceship.
## The force of the friction applied to the space when it's not moving.
@export var friction: float = 50.0

var is_moving: bool ## Set to [code]true[/code] when the spaceship is moving.
## Set to [code]true[/code] when the spaceship is playing the death animation.
var is_death: bool = false 
var has_invulnerability: bool = false

## Represents the amount of pixels that is needed so the sprite get out of screen entirely.
var limit_margin: Vector2 

var left_limit: float ## Position of the left side limit. (X Axis)
var right_limit: float ## Position of the right side limit. (X Axis)
var up_limit: float ## Position of the up side limit. (Y Axis)
var down_limit: float ## Position of the down side limit. (Y Axis)

@onready var moving_sound := $MovingSound
@onready var explosion_sound = $ExplosionSound
@onready var animated_sprite = $AnimatedSprite2D
@onready var moving_particles = $MovingParticles
@onready var kill_particles = $KillParticles
@onready var shot_particles = $ShotParticles
@onready var collision = $CollisionPolygon2D
@onready var bullets = $Bullets
## A reference to the coordinates where the bullets will spawn.
@onready var bullet_spawn_point = $BulletSpawnPoint
@onready var shot_cooldown = $ShotCooldown
@onready var animation_player = $AnimationPlayer

func _ready():
	self.process_mode = Node.PROCESS_MODE_INHERIT
	Global.no_lives_left.connect(_on_no_lives_left)
	
	global_position = Vector2i(450, 400)
	
	limit_margin = Vector2(30, 30)
	
	left_limit = 0 - limit_margin.x ## Position of the left limit (X Axis)
	right_limit = Global.SCREEN_SIZE.x + limit_margin.x ## Position of the right limit (X Axis)
	up_limit = 0 - limit_margin.y ## Position of the up limit (Y Axis)
	down_limit = Global.SCREEN_SIZE.y + limit_margin.x ## Position of the down limit (Y Axis)

func _physics_process(delta):
	if is_death:
		return
	
	_do_rotate(delta)
	_do_move(delta)
	
	if is_moving and !moving_sound.playing:
		moving_sound.play()
		animated_sprite.play("moving")
		moving_particles.emitting = true
	
	if !is_moving:
		moving_sound.stop()
		animated_sprite.stop()
		moving_particles.emitting = false

func _input(event):
	if event.is_action_pressed("shot") and !is_death:
		if shot_cooldown.is_stopped():
			shot()

## Shots a [Bullet] from [member SpaceShip.bullet_spawn_point] global position.
func shot() -> void:
	var bullet: Bullet = Bullet.create_bullet(self)
	bullet.global_position = bullet_spawn_point.global_position
	bullet.bullet_direction = Vector2.from_angle(global_rotation).rotated(-PI / 2)
	bullets.add_child(bullet)
	shot_cooldown.start()
	shot_particles.restart()

## Takes a life from the spaceship calling the [method Global.lose_life], doing
## a death animation and waiting 3 seconds to respawn at the center of the screen.
## [br][br]
## The method will check if the player has no lives left calling the
## [method Global.has_spaceship_lives]. If that's not the case, the game will
## show the [GameOverScreen].
func kill() -> void:
	if is_invulnerable():
		return
	else:
		Global.lose_life()
		is_death = true
		has_invulnerability = true
		explosion_sound.play()
		
		# Stops animations.
		moving_particles.emitting = false
		moving_sound.stop()
		animated_sprite.stop()
		
		# Hides sprite and emits death particles (also disables the collision).
		# Also moves the spaceship out of screen so any asteroid can
		# touch it.
		animated_sprite.hide()
		kill_particles.emitting = true
		global_position = Vector2i(100000, 100000)
		
		await get_tree().create_timer(3.0).timeout
		
		# Shows sprite, restarts the spaceship and finish the death animation
		# (only if the player has lives left.)
		if Global.has_spaceship_lives():
			respawn_with_invulnerability()

func is_invulnerable() -> bool:
	return has_invulnerability

func respawn_with_invulnerability() -> void:
	self.process_mode = Node.PROCESS_MODE_INHERIT
	animated_sprite.show()
	global_position = Vector2i(450, 400)
	velocity = Vector2.ZERO
	global_rotation = 0
	is_death = false
	
	animation_player.play("invulnerability")
	await animation_player.animation_finished
	
	has_invulnerability = false

## Function using to calculate the amount of rotation each frame depending of
## the user input. The parameter [param delta] comes from the parameter with
## the same name in [method Node._physics_process], which is used to do smooth
## animations.
func _do_rotate(delta: float) -> void:
	var rotation_direction: float = Input.get_axis("left", "right")
	var rotation_amount: float = rotation_direction * rotation_speed * delta
	
	rotate(rotation_amount)

## Function using to calculate the amount of movement each frame depending of
## the user input. The parameter [param delta] comes from the parameter with
## the same name in [method Node._physics_process], which is used to do smooth
## movement.
## [br][br]
## Also the method check every frame where the spaceship is and if it goes through
## the left border, it will appear from the right border and viceversa. Same goes
## to the up and down borders.
func _do_move(delta: float) -> void:
	var movement_amount: float = Input.get_action_strength("forward")
	
	if movement_amount == 0:
		velocity = velocity.move_toward(Vector2.ZERO, _adjusted_friction(delta))
		is_moving = false
	else:
		velocity += movement_amount * _adjusted_acceleration(delta) * Vector2.UP.rotated(rotation)
		velocity = velocity.limit_length(max_speed)
		is_moving = true
	
	move_and_slide()
	
	if global_position.y < up_limit:
		global_position.y = down_limit
	elif global_position.y > down_limit:
		global_position.y = up_limit
	
	if global_position.x < left_limit:
		global_position.x = right_limit
	elif global_position.x > right_limit:
		global_position.x = left_limit

## Returns the acceleration adjusted by the [param delta] which comes from the 
## parameter with the same name in [method Node._physics_process], used to do
## smooth movement.
func _adjusted_acceleration(delta: float) -> float:
	return acceleration * delta

## Returns the friction adjusted by the [param delta] which comes from the 
## parameter with the same name in [method Node._physics_process], used to do
## smooth movement.
func _adjusted_friction(delta: float) -> float:
	return friction * delta

func _on_no_lives_left():
	self.process_mode = Node.PROCESS_MODE_DISABLED
