@icon("res://assets/sprites/ufo_sprite.svg")
extends Area2D
class_name UFO

const UFO_SCENE: PackedScene = preload("res://scenes/ufo.tscn")

static var tier_1_points: int = 100
static var tier_2_points: int = 250

var player_reference: SpaceShip

## Represents the type:
## [br][br]
## Tier 1: Normal alien [br]
## Tier 2: Small alien
var tier: int = 1
var ufo_speed: float = 100 ## Represents the UFO speed.
var base_direction: Vector2 = Vector2.RIGHT
var limit: float ## Number in the X Axis where the UFO will despawn.

## Represents the amount of pixels that is needed so the sprite get out of screen entirely.
var limit_margin: Vector2 

var left_limit: float ## Position of the left side limit. (X Axis)
var right_limit: float ## Position of the right side limit. (X Axis)
var up_limit: float ## Position of the up side limit. (Y Axis)
var down_limit: float ## Position of the down side limit. (Y Axis)

@onready var diagonal_cooldown_timer = $DiagonalCooldownTimer
@onready var diagonal_duration_timer = $DiagonalDurationTimer
@onready var shot_cooldown = $ShotCooldown
@onready var bullets = $Bullets
@onready var destroy_particles = $DestroyParticles
@onready var medium_explosion_sound = $MediumExplosionSound
@onready var small_explosion_sound = $SmallExplosionSound
@onready var medium_movement_sound = $MediumMovementSound
@onready var small_movement_sound = $SmallMovementSound
@onready var sprite = $Sprite2D
@onready var collision_polygon_2d = $CollisionPolygon2D

static func create_alien() -> UFO:
	const SMALL_ALIEN_CHANCE: float = 0.4
		
	var new_alien: UFO = UFO_SCENE.instantiate()
	
	if randf() <= SMALL_ALIEN_CHANCE:
		new_alien.tier = 2
	else:
		new_alien.tier = 1
	
	return new_alien

func _ready():
	print("Alien update: +1 Alien spawned (Tier " + str(tier) + ")")
	_get_player_reference()
	limit_margin = Vector2(50, 50)
	
	left_limit = 0 - limit_margin.x ## Position of the left limit (X Axis)
	right_limit = Global.SCREEN_SIZE.x + limit_margin.x ## Position of the right limit (X Axis)
	up_limit = 0 - limit_margin.y ## Position of the up limit (Y Axis)
	down_limit = Global.SCREEN_SIZE.y + limit_margin.x ## Position of the down limit (Y Axis)
	
	match tier:
		1:
			scale = Vector2(0.8, 0.8)
			medium_movement_sound.play()
		2:
			scale = Vector2(0.4, 0.4)
			small_movement_sound.play()
	
	_start_shot_cooldown()
	_start_diagonal_cooldown()
	spawn()

func _process(delta):
	movement(delta)

func spawn():
	var spawn_side_choose = randi_range(0, 1)
	global_position.y = randf_range(up_limit + 50, down_limit - 50)
	
	if spawn_side_choose == 1:
		base_direction = Vector2.RIGHT
		global_position.x = left_limit
		limit = right_limit
	else:
		base_direction = Vector2.LEFT
		global_position.x = right_limit
		limit = left_limit

func movement(delta: float):
	var speed: Vector2 = ufo_speed * delta * base_direction
	global_position += speed * Global.global_speed
	
	if global_position.y < up_limit:
		global_position.y = down_limit
	elif global_position.y > down_limit:
		global_position.y = up_limit
	
	if global_position.x < left_limit and base_direction.x == -1:
		queue_free()
	elif global_position.x > right_limit and base_direction.x == 1:
		queue_free()

func shot():
	var bullet: Bullet = Bullet.create_bullet(self)
	
	match tier:
		1:
			bullet.bullet_direction = Vector2.from_angle(randf_range(0, TAU))
		2:
			var player_position: Vector2 = player_reference.global_position
			bullet.bullet_direction = self.global_position.direction_to(player_position)
	
	bullet.bullet_speed = 500.0
	bullet.global_position = self.global_position
	bullets.add_child(bullet)

func kill():
	var alien_points: int = 0
	destroy_particles.emitting = true
	shot_cooldown.stop()
	medium_movement_sound.stop()
	small_movement_sound.stop()
	collision_polygon_2d.queue_free()
	print("Alien update: Tier " + str(tier) + " alien destroyed.")
	
	match tier:
		1:
			medium_explosion_sound.play()
			alien_points = tier_1_points
		2:
			small_explosion_sound.play()
			alien_points = tier_2_points
	
	sprite.hide()
	Global.add_points(alien_points)
	await destroy_particles.finished
	queue_free()

func _start_shot_cooldown():
	var time = randf_range(1.5, 2.0) / Global.global_speed
	shot_cooldown.start(time)

func _start_diagonal_cooldown():
	base_direction.y = 0
	var time = randf_range(1.5, 5.0) / Global.global_speed
	diagonal_cooldown_timer.start(time)

func _start_diagonal_duration():
	var vertical_dir: int = randi_range(0, 1)
	
	if vertical_dir == 1:
		base_direction.y = 1
	else:
		base_direction.y = -1
	
	var time = randf_range(1.5, 3.5)
	diagonal_duration_timer.start(time)

func _get_player_reference():
	player_reference = get_tree().get_first_node_in_group("player")

func _on_diagonal_movement_timer_timeout():
	_start_diagonal_duration()

func _on_diagonal_duration_timer_timeout():
	_start_diagonal_cooldown()

func _on_shot_cooldown_timeout():
	shot()
	_start_shot_cooldown()

func _on_body_entered(body):
	if body.is_in_group("player") and !body.is_invulnerable():
		body.kill()
		self.kill()
