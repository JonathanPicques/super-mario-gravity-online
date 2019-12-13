extends Node2D
class_name ObjectInvincibilityNode

var player_node = null

func _ready():
	player_node.apply_object_invincibility(self)

func reset_player():
	player_node.reset_object_invincibility(self)
