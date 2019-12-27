extends "res://Game/Maps/Map.gd"

const PlayerCamera := preload("res://Game/Players/PlayerCamera2D.tscn")

var player_camera_scene = null

const SKIP_START_POSITION := Vector2(96, 240)

# @impure
func _ready():
	if !SettingsManager.values["show_tuto"]:
		$FlagStart.position = SKIP_START_POSITION
	else:
		SettingsManager.values["show_tuto"] = false # TODO: check if launch at least one game
		SettingsManager.save_settings()
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")

# @impure
func _process(delta: float):
	var lead_player = MultiplayerManager.get_lead_player()
	# goto lobby
	if lead_player and InputManager.is_player_action_just_pressed(lead_player.id, "accept"):
		set_process(false) # disable process to avoid calling goto_lobby_menu_scene multiple times.
		return Game.goto_lobby_menu_scene()
	if Input.is_action_just_pressed("ui_toggle_room_status"):
		Game.goto_settings_menu_scene()
	# add a local player
	if not lead_player:
		for input_device_id in range(0, 5):
			if InputManager.is_device_action_just_pressed(input_device_id, "accept") and not InputManager.is_device_used_by_player(input_device_id):
				yield(get_tree(), "idle_frame")
				MultiplayerManager.add_player("Local player", true, input_device_id, MultiplayerManager.my_peer_id, MultiplayerManager.get_next_player_local_id(MultiplayerManager.my_peer_id))
				$GUI/TitleLabel.visible = false
				$GUI/SubtitleLabel.visible = false 

	# add camera to player
	if !player_camera_scene and lead_player:
		$GUI/TitleLabel.visible = false
		$GUI/SubtitleLabel.visible = false 
		var player_node = MultiplayerManager.get_player_node(lead_player.id)
		if player_node:
			player_camera_scene = PlayerCamera.instance()
			player_camera_scene.player_node_path = player_node.get_path()
			player_camera_scene.tile_map_node_path = $Map.get_path()
			add_child(player_camera_scene)
	
