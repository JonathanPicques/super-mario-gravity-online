extends Node2D

const Chain := preload("res://Game/Items/SpikeBall/Chain.tscn")

export var length := 8
export var min_speed = 1
export var max_speed = 3
export var clockwise := true

onready var ball_node := $Offset/Ball
onready var offset_node := $Offset

onready var current_direction := 1 if clockwise else -1

var chain_nodes = []

const chain_space = 8

func _ready():
	for i in range(0, length - 1):
		var chain_node = Chain.instance()
		chain_node.position = Vector2(0, i * chain_space)
		chain_nodes.append(chain_node)
		offset_node.add_child(chain_node)
	ball_node.position = Vector2(0, length * chain_space)

func _process(delta):
	var half_height = length * chain_space
	var speed_factor = 1.0 - (offset_node.global_position.y - ball_node.global_position.y + half_height) / (2 * half_height)
	var rotation_delta = delta * lerp(min_speed, max_speed, speed_factor) * current_direction
	for chain_node in chain_nodes:
		chain_node.rotate(-rotation_delta)
	ball_node.rotate(-rotation_delta)
	offset_node.rotate(rotation_delta)

func _on_Area2D_body_entered(body):
	if body.is_in_group("PlayerNode"):
		body.apply_death(position + ball_node.position)
	else:
		current_direction *= -1

func get_map_data() -> Dictionary:
	return {
		"type": "SpikeBall",
		"position": [position.x, position.y],
		"length": length,
		"clockwise": clockwise
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	clockwise = item_data["clockwise"]
	length = item_data["length"]
