extends "res://Game/GameNetwork.gd"

enum GameState { none, home, lobby, connecting, connection_error, game_mode }

const HomeMenu = preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu = preload("res://Game/Menus/LobbyMenu.tscn")
const ConnectMenu = preload("res://Game/Menus/ConnectMenu.tscn")
const PlayerCamera = preload("res://Game/Players/PlayerCamera2D.tscn")

var state = GameState.none
var scene = null
var players := [
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
	connect("host", self, "on_host")
	connect("stop", self, "on_stop")
	connect("registered", self, "on_registered")
	connect("server_load_game_mode", self, "on_server_load_game_mode")
	connect("server_start_game_mode", self, "on_server_start_game_mode")
	connect("client_load_game_mode", self, "on_client_load_game_mode")
	connect("client_start_game_mode", self, "on_client_start_game_mode")
	# load home menu
	set_state(GameState.home)
	goto_home_menu_scene()

##########
# Scenes #
##########

# set_state sets the current state.
# @impure
func set_state(new_state: int):
	state = new_state

# set_scene sets the current scene and releases the previous one.
# @impure
func set_scene(new_scene: Node):
	if scene != null:
		remove_child(scene)
		scene.queue_free()
	add_child(new_scene)
	scene = new_scene

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

# on_host is called when we started a server successfully.
# @driven(signal)
# @impure
func on_host():
	set_state(GameState.lobby)
	goto_lobby_menu_scene()

# on_stop is called when we stopped playing as a server or as a client or an error happened.
# @driven(signal)
# @impure
func on_stop(error: int):
	match error:
		StopError.none:
			set_state(GameState.home)
			goto_home_menu_scene()
		StopError.hosting_failed:
			set_state(GameState.connection_error)
			goto_connect_menu_scene(StopError.hosting_failed)
		StopError.joining_failed:
			set_state(GameState.connection_error)
			goto_connect_menu_scene(StopError.joining_failed)
		StopError.connection_lost:
			set_state(GameState.connection_error)
			goto_connect_menu_scene(StopError.connection_lost)
		StopError.connection_failed:
			set_state(GameState.connection_error)
			goto_connect_menu_scene(StopError.connection_failed)

# on_registered is called when we registered to the server.
# @driven(signal)
# @impure
func on_registered():
	set_state(GameState.lobby)
	goto_lobby_menu_scene()

# on_server_load_game_mode is called on the server to load a game mode.
# @driven(signal)
# @impure
func on_server_load_game_mode():
	var game_mode_path := "res://Game/Modes/Race/RaceGameMode.tscn"
	var game_mode_options := {map = "res://Game/Maps/Base/Base.tscn"}
	# we get to load the game mode we want
	var game_mode_scene = load(game_mode_path).instance()
	game_mode_scene.options = game_mode_options
	# set the scene
	set_scene(game_mode_scene)
	set_state(GameState.game_mode)
	# tell the other peers to load the given game mode like us
	net_load_game_mode(game_mode_path, game_mode_options)

# client_load_game_mode is called by the server to tell us to load the given game mode.
# @driven(signal)
# @impure
func on_client_load_game_mode(game_mode_path: String, game_mode_options: Dictionary):
	# load the game mode 
	var game_mode_scene = load(game_mode_path).instance()
	game_mode_scene.options = game_mode_options
	# load the game mode
	set_scene(game_mode_scene)
	set_state(GameState.game_mode)
	# tell the server we loaded the game mode
	rpc_id(1, "net_loaded_game_mode")

# on_server_start_game_mode is called on the server to start the game mode.
# @driven(signal)
# @impure
func on_server_start_game_mode():
	scene.start()

# on_server_start_game_mode is called on the client to start the game mode.
# @driven(signal)
# @impure
func on_client_start_game_mode():
	scene.start()
