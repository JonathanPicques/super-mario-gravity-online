extends Node2D

export var length := 8
export var rotation_speed = 2

onready var Chain =  preload("res://Game/Items/SpikeBall/Chain.tscn")

onready var offset_node = $Offset
onready var ball_node = $Offset/Ball

var chain_nodes = []

const chain_space = 8

var current_direction = 1

func _ready():
	for i in range(0, length - 1):
		var chain_node = Chain.instance()
		chain_node.position = Vector2(0, i * chain_space)
		chain_nodes.append(chain_node)
		offset_node.add_child(chain_node)
	ball_node.position = Vector2(0, length * chain_space)

func _process(delta):
	for chain_node in chain_nodes:
		chain_node.rotate(-delta * rotation_speed * current_direction)
	ball_node.rotate(-delta * rotation_speed * current_direction)
	offset_node.rotate(delta * rotation_speed * current_direction)


func _on_Area2D_body_entered(body):
	if body.is_in_group("PlayerNode"):
		body.apply_death(position + ball_node.position)
	else:
		current_direction *= -1
