extends Control

func _ready():
	var map_node = load("res://Game/Maps/Home/Home.tscn").instance()
	$MapSlot.add_child(map_node)
