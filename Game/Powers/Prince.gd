extends Node2D
class_name ObjectPrinceNode

var player_node = null

func _ready():
	player_node.apply_object_prince(self)

func reset_player():
	player_node.reset_object_prince(self)
