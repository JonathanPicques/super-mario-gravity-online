extends Node
class_name InputManagerNode

func is_player_action_pressed(player_id: int, action: String):
	var player = MultiplayerManager.get_player(player_id)
	return is_device_action_pressed(player.input_device_id, action)

func is_player_action_just_pressed(player_id: int, action: String):
	var player = MultiplayerManager.get_player(player_id)
	return is_device_action_just_pressed(player.input_device_id, action)

func is_device_action_pressed(device_id: int, action: String):
	return Input.is_action_pressed("device_%d_%s" % [device_id, action])

func is_device_action_just_pressed(device_id: int, action: String):
	return Input.is_action_just_pressed("device_%d_%s" % [device_id, action])

func is_device_used_by_player(device_id: int):
	for player in MultiplayerManager.get_players():
		if player.input_device_id == device_id:
			return true
	return false
