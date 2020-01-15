extends Node2D

var used := false

func _on_Area2D_body_entered(player_node: PlayerNode):
	if not used:
		used = true
		if Game.game_mode_node is RaceGameModeNode:
			Game.game_mode_node.call_deferred("end_race", player_node.player.id)

func get_map_data() -> Dictionary:
	return {
		"type": "FlagEnd",
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
