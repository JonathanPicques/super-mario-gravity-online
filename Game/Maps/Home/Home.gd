extends Navigation2D

onready var Game = get_node("/root/Game")
onready var MapSlot = $"."

func _ready():
	Game.GameMultiplayer.connect("player_added", self, "on_player_added")

func _process(delta: float):
	var lead_player = Game.GameMultiplayer.get_lead_player()
	# goto lobby
	if lead_player and Game.GameInput.is_player_action_just_pressed(lead_player.id, "accept"):
		Game.goto_lobby_menu_scene()
	# add a local player
	if not lead_player:
		for input_device_id in range(0, 5):
			if Game.GameInput.is_device_action_just_pressed(input_device_id, "accept") and not Game.GameInput.is_device_used_by_player(input_device_id):
				yield(get_tree(), "idle_frame")
				Game.GameMultiplayer.add_player("Local player", true, input_device_id, Game.GameMultiplayer.my_peer_id, Game.GameMultiplayer.get_next_peer_player_id(Game.GameMultiplayer.my_peer_id))

func on_player_added(player: Dictionary):
	var player_node = Game.GameMultiplayer.spawn_player_node(player, MapSlot)
	# TODO: spawn GFX
	player_node.position = $FlagStart.position
