extends Node2D

onready var Spawn1: Node2D = $Spawn1
onready var Spawn2: Node2D = $Spawn2
onready var Spawn3: Node2D = $Spawn3
onready var Spawn4: Node2D = $Spawn4

func get_map_data() -> Dictionary:
	return {
		"type": "StartCage",
		"position": [position.x, position.y]
	}

func load_map_data(item_data: Dictionary):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(96, 96))

func _on_Timer_timeout():
	$AnimatedSprite.play("open")
	$Door/CollisionShape2D.disabled = true
