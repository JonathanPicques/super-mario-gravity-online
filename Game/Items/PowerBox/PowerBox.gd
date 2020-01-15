extends Node2D

onready var Effect = preload("res://Game/Items/PowerBox/CollectedEffect.tscn")
onready var RespawnTimer = $Timer

func _on_Area2D_body_entered(player_node):
	if not player_node.power_node:
		player_node.grab_power(4)
		var effect_node = Effect.instance()
		effect_node.position = $EffectPosition.global_position
		get_parent().add_child(effect_node)
		visible = false
		RespawnTimer.start()
	pass

func _on_Timer_timeout():
	visible = true

func get_map_data() -> Dictionary:
	return {
		"type": "PowerBox",
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
