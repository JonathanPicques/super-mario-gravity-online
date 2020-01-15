extends KinematicBody2D

export(SkinManagerNode.SkinColor) var color: int = SkinManagerNode.SkinColor.pink

const SPEED := 120.0

var player_node: PlayerNode
var target_player_node: PlayerNode

func _ready():
	SkinManager.replace_skin($Sprite, color)
	SkinManager.replace_skin($AnimatedSprite, color)

func _physics_process(delta: float):
	var velocity := ((target_player_node.position - position).normalized() * SPEED * delta) if is_instance_valid(target_player_node) else Vector2(SPEED * delta * cos(rotation), SPEED * delta * sin(rotation))
	var collision := move_and_collide(Vector2(SPEED * delta * cos(rotation), SPEED * delta * sin(rotation)))
	rotation = velocity.angle()
	if collision:
		if collision.collider is PlayerNode:
			collision.collider.apply_death(position)
		queue_free()
