extends Node2D

onready var Straight = preload("res://Game/Items/Trampoline/Textures/Trampoline.png")
onready var Diagonal = preload("res://Game/Items/Trampoline/Textures/TrampolineDiagonal.png")

var isDiagonal = false

func _on_Area2D_body_entered(body):
	body.apply_expulse(Vector2(cos(rotation), sin(rotation)))
	$AnimationPlayer.play("TrampolineDiagonal" if isDiagonal else "Trampoline")

func get_map_data() -> Dictionary:
	var variation = -1
	if rotation_degrees == 0 and not isDiagonal:
		variation = 0
	elif rotation_degrees == 90 and not isDiagonal:
		variation = 1
	elif rotation_degrees == 180 and not isDiagonal:
		variation = 2
	elif rotation_degrees == -90 and not isDiagonal:
		variation = 3
	elif rotation_degrees == 90 and isDiagonal:
		variation = 4
	elif rotation_degrees == 180 and isDiagonal:
		variation = 5
	elif rotation_degrees == 0 and isDiagonal:
		variation = 6
	elif rotation_degrees == -90 and isDiagonal:
		variation = 7
	return {
		"type": "Trampoline",
		"position": [position.x, position.y],
		"variation": variation
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
	isDiagonal = false
	if not ("variation" in item_data):
		rotation_degrees = item_data["rotation"]
	elif item_data["variation"] == 0:
		#$Sprite.texture = Straight
		rotation_degrees = 0
	elif item_data["variation"] == 1:
		#$Sprite.texture = Straight
		rotation_degrees = 90
	elif item_data["variation"] == 2:
		#$Sprite.texture = Straight
		rotation_degrees = 180
	elif item_data["variation"] == 3:
		#$Sprite.texture = Straight
		rotation_degrees = -90
	elif item_data["variation"] == 4:
		#$Sprite.texture = Diagonal
		isDiagonal = true
		rotation_degrees = 90#45
	elif item_data["variation"] == 5:
		#$Sprite.texture = Diagonal
		isDiagonal = true
		rotation_degrees = 180#135
#		$Sprite.global_position.x -= 16
	elif item_data["variation"] == 6:
		#$Sprite.texture = Diagonal
		isDiagonal = true
		rotation_degrees = 0#-45
#		$Sprite.global_position.x -= 16
	elif item_data["variation"] == 7:
		#$Sprite.texture = Diagonal
		isDiagonal = true
		$Sprite.position.y -= 16
		rotation_degrees = -90#-135
#		$Sprite.global_position.x -= 16
	$AnimationPlayer.play("TrampolineDiagonalIdle" if isDiagonal else "TrampolineIdle")

func quadtree_item_rect() -> Rect2:
	return Rect2(position, $Sprite.get_rect().size)
