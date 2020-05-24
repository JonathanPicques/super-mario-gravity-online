extends Node2D
class_name ScarecrowNode

onready var Target = $Body/Target
onready var RespawnTimer = $RespawnTimer

func apply_death(death_origin: Vector2):
	visible = false
	RespawnTimer.start()


func _on_RespawnTimer_timeout():
	visible = true
