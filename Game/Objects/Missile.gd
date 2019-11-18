extends Node2D

var SPEED := 350
var STEER_FORCE := 50.0

onready var Game = get_node("/root/Game")
var velocity := Vector2.ZERO
var acceleration := Vector2.ZERO
var direction := 1
var player = null
var target = null

func _ready():
	direction = player.direction
	$Sprite.scale.x = abs($Sprite.scale.x) * sign(direction)
	velocity = transform.x * SPEED
	target = Game.GameMultiplayer.get_closest_player(player.player_id)

func _physics_process(delta):
	acceleration += seek_target()
	velocity += acceleration * delta
	velocity = velocity.clamped(SPEED)
	rotation = velocity.angle()
	position += velocity * delta * direction

func seek_target():
#	if target:
#		var target_velocity = (target.position - position).normalized() * SPEED
#		return (target_velocity - velocity).normalized() * STEER_FORCE
	return Vector2.ZERO

func _on_Area2D_body_entered(body):
	if player != body: # don't check collision on current player
		# FIXME: kill the player if there is one (how to check??)
		print("KILL PLAYER!")
		queue_free()

func _on_Timer_timeout():
	print("Missile timed out")
	queue_free()
