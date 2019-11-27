extends Node2D

const SPEED := 250
export var use_target := false

var player_node = null

onready var Game = get_node("/root/Game")

var target_node = null
var direction := 1

func _ready():
	direction = player_node.direction
	$Sprite.scale.x = abs($Sprite.scale.x) * sign(direction)
	if use_target:
		var closest = Game.GameMultiplayer.get_closest_player(player_node.player.id)
		if closest:
			target_node = Game.GameMultiplayer.get_player_node(closest.id)

func _physics_process(delta: float):
	if is_instance_valid(target_node):
		var v = (target_node.position - position).normalized() * SPEED * delta
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
