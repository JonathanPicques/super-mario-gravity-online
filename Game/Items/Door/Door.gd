extends Node2D

export var exit_node_path: NodePath

onready var target = $Target
var exit_node = null

func _ready():
	if exit_node_path:
		exit_node = get_node(exit_node_path)

func _on_Area2D_body_entered(body):
	if exit_node:
		body.set_door(self, exit_node)


func _on_Area2D_body_exited(body):
	body.set_door(null, null)
