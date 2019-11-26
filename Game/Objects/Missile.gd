extends Node2D

const SPEED := 5
const STEER_FORCE := 20

var target = null
var velocity := Vector2.ZERO
var direction := 1
var player_node = null
var acceleration := Vector2.ZERO

func _ready():
	direction = player_node.direction
	$Sprite.scale.x = abs($Sprite.scale.x) * sign(direction)
	target = get_node("/root/Game/RaceGameMode/SplitScreenContainer/RowContainer1/ColumnContainer1/ViewportContainer1/Viewport1/MapSlot/Base/Target")

func _physics_process(delta: float):
	if target:
		var v = (target.position - position).normalized() * SPEED
		rotation = v.angle()
		position += v
	else:
		position += Vector2(direction * SPEED * delta, 0)

func _on_Area2D_body_entered(body):
	if player_node != body: # don't check collision on current player
		# FIXME: kill the player if there is one (how to check??)
		if body.is_in_group("PlayerNode"):
			print("Missile collided width player ", body.player.id)
		else:
			print("Missile collided with ", body.name)
		queue_free()

func _on_Timer_timeout():
	print("TODO: free()")
	queue_free()
