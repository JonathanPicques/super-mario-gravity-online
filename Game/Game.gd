extends "res://Game/GameNetwork.gd"

enum GameState { none, home, lobby, connecting, connection_error, loading_game_mode, playing_game_mode }

const HomeMenu = preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu = preload("res://Game/Menus/LobbyMenu.tscn")
const ConnectMenu = preload("res://Game/Menus/ConnectMenu.tscn")
const PlayerCamera = preload("res://Game/Players/Cam/PlayerCamera2D.tscn")

var state = GameState.none
var current_scene = null

var Players := [
	{
		name = "Mario",
		scene_path = "res://Game/Players/Mario/Mario.tscn",
		preview_path = "res://Game/Players/Mario/Textures/Stand/stand_01.png",
	},
	{
		name = "Luigi",
		scene_path = "res://Game/Players/Luigi/Luigi.tscn",
		preview_path = "res://Game/Players/Luigi/Textures/Stand/stand_01.png",
	}
]

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	# connect signals
	connect("self_peer_hosted", self, "on_self_peer_hosted")
	connect("self_peer_stopped", self, "on_self_peer_stopped")
	connect("peer_registered", self, "on_peer_registered")
	connect("peer_unregistered", self, "on_peer_unregistered")
	connect("peer_selected_player", self, "on_peer_selected_player")
	connect("server_started_game_mode", self, "on_server_started_game_mode")
	# load home menu
	goto_home_menu_scene()

##########
# Scenes #
##########

# set_scene sets the current scene and releases the previous one.
# @impure
func set_scene(scene: Node):
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
	add_child(scene)
	current_scene = scene

# goto_home_menu loads and go to the home menu.
# @impure
func goto_home_menu_scene():
	var home_menu_scene := HomeMenu.instance()
	set_scene(home_menu_scene)
	home_menu_scene.connect("host_game", self, "net_host")
	home_menu_scene.connect("join_game", self, "net_join")

# goto_home_menu loads and go to the lobby menu.
# @impure
func goto_lobby_menu_scene():
	var lobby_menu_scene := LobbyMenu.instance()
	set_scene(lobby_menu_scene)
	lobby_menu_scene.connect("stop_game", self, "net_stop")

# goto_connect_menu_scene loads and go to the connect menu (to either display connecting or connection error message).
# @impure
func goto_connect_menu_scene(error:= StopError.none):
	var connect_menu_scene := ConnectMenu.instance()
	set_scene(connect_menu_scene)
	connect_menu_scene.connect("stop_game", self, "net_stop")
	connect_menu_scene.set_error(error)

###############
# Peer events #
###############

# on_self_peer_hosted is called when we started a server successfully.
# @driven(signal)
# @impure
func on_self_peer_hosted():
	goto_lobby_menu_scene()

# on_self_peer_stopped is called when we stopped playing as a server or client.
# @driven(signal)
# @impure
func on_self_peer_stopped(error: int):
	match error:
		StopError.none: goto_home_menu_scene()
		StopError.hosting_failed: goto_connect_menu_scene(StopError.hosting_failed)
		StopError.joining_failed: goto_connect_menu_scene(StopError.joining_failed)
		StopError.connection_lost: goto_connect_menu_scene(StopError.connection_lost)
		StopError.connection_failed: goto_connect_menu_scene(StopError.connection_failed)

# on_peer_registered is called when a peer is registered.
# @driven(signal)
# @impure
func on_peer_registered(peer_id: int, peer_info: Dictionary):
	# if our peer is registered, go to lobby
	if peer_id == self_peer.id:
		goto_lobby_menu_scene()

# on_peer_unregistered is called when a peer is unregistered.
# @driven(signal)
# @impure
func on_peer_unregistered(peer_id: int):
	pass

# on_peer_selected_player is called when a peer selected a player.
# @driven(signal)
# @impure
func on_peer_selected_player(peer_id: int, player_id: int, player_ready: bool):
	# if we are the server and all peers are ready, start the game mode
	if get_tree().is_network_server() and is_every_peer_ready():
		net_server_start_game_mode("res://Game/Modes/Race/RaceGameMode.tscn", {map = "res://Game/Maps/Base/Base.tscn"})

# on_server_started_game_mode is called when the server started a game mode.
# @driven(signal)
# @impure
func on_server_started_game_mode(game_mode_scene: Node):
	set_scene(game_mode_scene)