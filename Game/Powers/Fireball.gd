extends Node2D

const SPEED := 250

export var use_target := false
export(SkinManagerNode.SkinColor) var color: int = SkinManagerNode.SkinColor.pink

var direction := 1
var player_node = null
var target_node = null

func _ready():
	direction = player_node.direction
	SkinManager.replace_skin($Sprite, color)
	SkinManager.replace_skin($AnimatedSprite, color)
	$AnimatedSprite.scale.x = abs($AnimatedSprite.scale.x) * sign(direction)
	if use_target:
		print("Use target !")
		var closest = MultiplayerManager.get_closest_player(player_node.player.id)
		if closest:
			target_node = MultiplayerManager.get_player_node(closest.id)
			print("Use firebase with target ", target_node.name)

func _physics_process(delta: float):
	if is_instance_valid(target_node):
		var v = (target_node.position - position).normalized() * SPEED * delta
		rotation = v.angle()
		position += v
	else:
		position += Vector2(direction * SPEED * delta, 0)

func _on_Area2D_body_entered(body):
	if player_node != body: # don't check collision on current player
		if body.is_in_group("PlayerNode"):
			body.apply_death(position)
		else:
			print("Missile collided with ", body.name)
		queue_free()

func _on_Timer_timeout():
	print("TODO: free()")
	queue_free()
