extends Navigation2D

onready var MapSlot = $"."

func _ready():
	GameMultiplayer.connect("player_added", self, "on_player_added")

func _process(delta: float):
	var lead_player = GameMultiplayer.get_lead_player()
	# goto lobby
	if lead_player and GameInput.is_player_action_just_pressed(lead_player.id, "accept"):
		Game.goto_lobby_menu_scene()
	# add a local player
	if not lead_player:
		for input_device_id in range(0, 5):
			if GameInput.is_device_action_just_pressed(input_device_id, "accept") and not GameInput.is_device_used_by_player(input_device_id):
				yield(get_tree(), "idle_frame")
				GameMultiplayer.add_player("Local player", true, input_device_id, GameMultiplayer.my_peer_id, GameMultiplayer.get_next_peer_player_id(GameMultiplayer.my_peer_id))

func on_player_added(player: Dictionary):
	var player_node := GameMultiplayer.spawn_player_node(player, MapSlot)
	# TODO: spawn GFX
	GameConst.replace_skin(player_node.PlayerSprite, 0)
	player_node.set_dialog(0)
	player_node.position = $FlagStart.position
