@icon("res://assets/sprites/bullet.svg")
extends Area2D
class_name Bullet

## This class is a point that once is spawned, will go in a straight line until his
## lifespan is over.
##
## Once has spawned, it will use [member bullet_speed] and [member bullet_direction] 
## properties to determine in which direction will go and with which speed. It 
## will go in a straight line until one of this two things happens:
## [br][br]
## 1. His lifespan ends and it despawns.[br]
## 2. It collides with an enemy. It can be an asteroid, alien, etc... It will
## despawn and hurt the enemy.

## A reference to the [PackedScene] of a [Bullet].
const BULLET_SCENE: PackedScene = preload("res://scenes/bullet.tscn") 

## Reference to the [Timer] that represents his lifespan.
@onready var bullet_lifespan := $BulletLifespan 
@onready var shooting_sound = $ShootingSound

var bullet_owner: Variant ## Reference to the shooter of the bullet.

var bullet_speed: float = 750.0 ## The speed of the bullet.
var bullet_direction: Vector2 ## The direction of the bullet.

## Returns an instance of a [Bullet]. Is needed to provide the owner of the bullet,
## using the reserved word [code]self[/code] or providing other 
## type of reference of the shooter.
static func create_bullet(shooter: Variant) -> Bullet:
	var new_bullet: Bullet = BULLET_SCENE.instantiate()
	new_bullet.bullet_owner = shooter
	return new_bullet

func _ready():
	bullet_lifespan.start()
	shooting_sound.play()

func _physics_process(delta):
	var speed: Vector2 = bullet_speed * bullet_direction * delta
	global_position += speed
	
	if global_position.y < -4:
		global_position.y = Global.SCREEN_SIZE.y + 4
	elif global_position.y > Global.SCREEN_SIZE.y + 4:
		global_position.y = -4
	
	if global_position.x < -4:
		global_position.x = Global.SCREEN_SIZE.x + 4
	elif global_position.x > Global.SCREEN_SIZE.x + 4:
		global_position.x = -4


func _on_bullet_lifespan_timeout():
	queue_free() 



func _on_body_entered(body):
	if bullet_owner is UFO:
		
		if body.is_in_group("player"):
			body.kill()
			queue_free()


func _on_area_entered(area):
	
	if area.is_in_group("asteroid") and !area.is_destroyed:
		area.destroy()
		queue_free()
	
	if bullet_owner is SpaceShip:
		
		if area.is_in_group("alien"):
			area.kill()
			queue_free()
