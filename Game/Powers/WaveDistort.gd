extends Node2D
class_name ObjectWaveDistortNode

var player_node = null

func _ready():
	player_node.apply_object_wave_distort(self)

func reset_player():
	player_node.reset_object_wave_distort(self)
