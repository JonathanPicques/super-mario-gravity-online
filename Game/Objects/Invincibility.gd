extends Node2D

var player_node = null

func _ready():
	player_node.apply_object_invincibility(self)
