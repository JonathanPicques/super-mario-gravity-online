extends Node2D
class_name ObjectSpeedNode

var player_node = null

func _ready():
	player_node.apply_object_speed(self)
