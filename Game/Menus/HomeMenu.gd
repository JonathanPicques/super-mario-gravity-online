extends "res://Game/Maps/Map.gd"

# @impure
func _process(delta: float):
	var lead_player = GameMultiplayer.get_lead_player()
	# goto lobby
	if lead_player and GameInput.is_player_action_just_pressed(lead_player.id, "accept"):
		set_process(false) # disable process to avoid calling goto_lobby_menu_scene multiple times.
		return Game.goto_lobby_menu_scene()
	# add a local player
	if not lead_player:
		for input_device_id in range(0, 5):
			if GameInput.is_device_action_just_pressed(input_device_id, "accept") and not GameInput.is_device_used_by_player(input_device_id):
				yield(get_tree(), "idle_frame")
				GameMultiplayer.add_player("Local player", true, input_device_id, GameMultiplayer.my_peer_id, GameMultiplayer.get_next_player_local_id(GameMultiplayer.my_peer_id))
