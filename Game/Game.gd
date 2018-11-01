extends Control

const Base = preload("res://Game/Maps/Base/Base.tscn")
const HomeMenu = preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu = preload("res://Game/Menus/LobbyMenu.tscn")
const ConnectMenu = preload("res://Game/Menus/ConnectMenu.tscn")

enum GameState {
	None,
	Home,
	Lobby,
	LoadMap,
	InGameMap,
	Connecting,
	ConnectError,
	ResultScreen,
}

var state = GameState.None

var current_ip = ""
var current_port = 0
var current_scene: Node = null
var current_max_players = 0
var current_listen_server = false

var player = {id = 0, index = 0, name = "root", skin = "mario"}
var players = {}

# _ready is called when the node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	get_tree().connect("connection_failed", self, "on_connection_failed")
	get_tree().connect("connected_to_server", self, "on_connected_to_server")
	get_tree().connect("server_disconnected", self, "on_server_disconnected")
	get_tree().connect("network_peer_connected", self, "on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "on_network_peer_disconnected")
	# go to home menu scene
	goto_home_menu_scene()

# set_state changes the game state.
# @impure
func set_state(new_state: int):
	state = new_state

# set_scene sets the current scene and disposes of the previous one.
# @impure
func set_scene(scene: Node):
	if current_scene != null:
		remove_child(current_scene)
		current_scene.queue_free()
	add_child(scene)
	current_scene = scene

# goto_home_menu loads the home menu.
# @impure
func goto_home_menu_scene():
	var home_menu_scene = HomeMenu.instance()
	home_menu_scene.connect("host_game", self, "host_game")
	home_menu_scene.connect("join_game", self, "join_game")
	set_scene(home_menu_scene)

# goto_error_menu loads the error menu.
# @impure
func goto_connect_menu_scene():
	var error_menu_scene = ConnectMenu.instance()
	error_menu_scene.connect("stop_game", self, "stop_game")
	set_scene(error_menu_scene)

# goto_home_menu loads the lobby menu.
# @impure
func goto_lobby_menu_scene():
	var lobby_menu_scene = LobbyMenu.instance()
	set_scene(lobby_menu_scene)

# host_game hosts a game on the given port with the given number of max players.
# @impure
func host_game(port: int, max_players: int, listen_server = true, player_name: String = "server") -> bool:
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_server(port, max_players) == 0:
		current_port = port
		current_max_players = max_players
		current_listen_server = listen_server
		setup_self(peer, player_name)
		net_player_configured(player)
		return true
	return false

# join_game joins a game on the given ip:port.
# @impure
func join_game(ip: String, port: int, player_name: String = "client") -> bool:
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_client(ip, port) == 0:
		current_ip = ip
		current_port = port
		set_state(GameState.Connecting)
		setup_self(peer, player_name)
		goto_connect_menu_scene()
		return true
	return false

# stop_game stops hosting or playing as a client.
# @impure
func stop_game():
	var peer = get_tree().get_meta("network_peer")
	if peer != null:
		peer.close_connection()
		player.id = 0
		player.index = 0
		get_tree().set_meta("network_peer", null)
	# return to home menu scene
	set_state(GameState.Home)
	goto_home_menu_scene()

# setup_self is called when successfully hosted or joined.
# @impure
func setup_self(peer: NetworkedMultiplayerPeer, player_name: String):
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	player.id = get_tree().get_network_unique_id()
	player.name = player_name

# on_connection_failed is called when joining (not hosting) failed.
# @driven(signal)
# @impure
func on_connection_failed():
	# connect error state
	set_state(GameState.ConnectError)
	# display connection failed error
	current_scene.set_state(current_scene.ConnectState.ConnectionFailed)

# on_connected_to_server is called when joining (not hosting) successfully.
# @driven(signal)
# @impure
func on_connected_to_server():
	# send our configuration to the server
	rpc_id(1, "net_player_configure", player)

# on_server_disconnected is called when the connection to the server is lost.
# @driven(signal)
# @impure
func on_server_disconnected():
	# error state
	set_state(GameState.ConnectError)
	# load error menu scene
	goto_connect_menu_scene()
	# display connection lost error
	current_scene.set_state(current_scene.ConnectState.ConnectionLost)

# on_network_peer_connected is called when another peer is connected.
# @driven(signal)
# @impure
func on_network_peer_connected(peer_id: int):
	pass

# on_network_peer_disconnected is called when another peer is disconnected.
# @driven(signal)
# @impure
func on_network_peer_disconnected(peer_id: int):
	if get_tree().is_network_server():
		# send to other players the disconnected player id
		rpc("net_player_disconnected", peer_id)
		# removes the player from the players list
		net_player_disconnected(peer_id)

# net_player_configure is called on the server when a new player sends its config.
# @driven(client_to_server)
# @impure
master func net_player_configure(new_player_config: Dictionary):
	# check if rpc sender id match player config
	if get_tree().get_rpc_sender_id() != new_player_config.id:
		print("net_player_configure(): warning: player id mismatch")
		get_tree().get_network_peer().disconnect_peer(get_tree().get_rpc_sender_id())
		return
	# compute new player index
	new_player_config.index = get_next_player_index()
	# tell the player he is configured
	rpc_id(new_player_config.id, "net_player_configured", new_player_config)
	# if the server is playing, send its info too to the new player
	if current_listen_server:
		rpc_id(new_player_config.id, "net_player_configured", player)
	# send new player info to the other connected players and the other way around
	for other_player_id in players:
		rpc_id(other_player_id, "net_player_configured", new_player_config)
		rpc_id(new_player_config.id, "net_player_configured", players[other_player_id])
	# add the new player to the players list
	net_player_configured(new_player_config)

# net_other_player_configured is called when the server tells us the given player is correctly configured.
# @driven(server_to_client)
# @impure
remote func net_player_configured(player_config: Dictionary):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_other_player_configured(): warning sender is not server")
	if player_config.id == player.id:
		# save our config
		player = player_config
		# go to lobby menu scene upon successful connection
		set_state(GameState.Lobby)
		goto_lobby_menu_scene()
	# add the configured player to the players
	players[player_config.id] = player_config
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_players(players)
	print("net_player_configured: ", player_config)

# net_other_player_disconnected is called when the server tells us another player has disconnected.
# @driven(server_to_client)
# @impure
remote func net_player_disconnected(player_id: int):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_other_player_disconnected(): warning sender is not server")
	# if our player is disconnected, we got kicked
	if player.id == player_id:
		# connect error state
		set_state(GameState.ConnectError)
		# go to connect menu scene and ...
		goto_connect_menu_scene()
		# ... display kick message
		current_scene.set_state(current_scene.ConnectState.ConnectionKicked)
	# remove the disconnected player from the players
	players.erase(player_id)
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_players(players)
	print("net_player_disconnected: ", player_id)

# get_next_player_index returns the next player index available.
# @pure
func get_next_player_index() -> int:
	var index = 1 if current_listen_server else 0
	for other_player_id in players:
		var other_player_index = players[other_player_id].index
		if index == other_player_index:
			index += 1
	return index