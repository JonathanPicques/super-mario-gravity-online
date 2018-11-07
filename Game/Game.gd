extends Control

const Base = preload("res://Game/Maps/Base/Base.tscn")
const HomeMenu = preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu = preload("res://Game/Menus/LobbyMenu.tscn")
const ConnectMenu = preload("res://Game/Menus/ConnectMenu.tscn")

onready var Players = preload("res://Game/Players/Players.gd").new()

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
var current_scene: Node
var current_max_peers = 0
var current_listen_server = false

var peer = {        # self peer
	id = 0,         # peer network id
	name = "",      # peer name
	index = 0,      # peer index (order of connection)
	ready = false,  # peer ready
	ingame = false, # peer in game
	player_id = 0   # peer player id (Mario = 0, Luigi = 1, ...)
}
var peers = {}

# _ready is called when the game node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	get_tree().connect("connection_failed", self, "on_connection_failed")
	get_tree().connect("connected_to_server", self, "on_connected_to_server")
	get_tree().connect("server_disconnected", self, "on_server_disconnected")
	get_tree().connect("network_peer_connected", self, "on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "on_network_peer_disconnected")
	# go to home menu scene
	set_state(GameState.Home)
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

# goto_home_menu loads the lobby menu.
# @impure
func goto_lobby_menu_scene():
	var lobby_menu_scene = LobbyMenu.instance()
	lobby_menu_scene.connect("stop_game", self, "stop_game")
	set_scene(lobby_menu_scene)

# goto_error_menu loads the error menu.
# @impure
func goto_connect_menu_scene():
	var error_menu_scene = ConnectMenu.instance()
	error_menu_scene.connect("stop_game", self, "stop_game")
	set_scene(error_menu_scene)

# host_game hosts a game on the given port with the given number of max peers.
# @impure
func host_game(port: int, max_peers: int, listen_server = true, peer_name: String = "server") -> bool:
	var mp_peer = NetworkedMultiplayerENet.new()
	if mp_peer.create_server(port, max_peers) == 0:
		current_port = port
		current_max_peers = max_peers
		current_listen_server = listen_server
		setup_self(mp_peer, peer_name)
		net_peer_configured(peer)
		return true
	return false

# join_game joins a game on the given ip:port.
# @impure
func join_game(ip: String, port: int, peer_name: String = "client") -> bool:
	var mp_peer = NetworkedMultiplayerENet.new()
	if mp_peer.create_client(ip, port) == 0:
		current_ip = ip
		current_port = port
		set_state(GameState.Connecting)
		setup_self(mp_peer, peer_name)
		goto_connect_menu_scene()
		return true
	return false

# stop_game stops hosting or playing as a client.
# @impure
func stop_game(return_home: bool = true):
	var mp_peer = get_tree().get_network_peer()
	if mp_peer != null:
		# close connection
		mp_peer.close_connection()
		# reset network peer
		get_tree().set_network_peer(null)
		# reset self peer values
		peer.id = 0
		peer.index = 0
		peer.ready = false
		# remove all other peers
		peers.clear()
	# return to home menu scene
	if return_home:
		set_state(GameState.Home)
		goto_home_menu_scene()

# setup_self is called when successfully hosted or joined.
# @impure
func setup_self(mp_peer: NetworkedMultiplayerPeer, peer_name: String):
	# save multiplayer peer for later use
	get_tree().set_network_peer(mp_peer)
	# assign self peer id/name
	peer.id = get_tree().get_network_unique_id()
	peer.name = peer_name

# on_connection_failed is called when joining (not hosting) failed.
# @driven(signal)
# @impure
func on_connection_failed():
	# stop game
	stop_game(false)
	# connect error state
	set_state(GameState.ConnectError)
	# display connection failed error
	current_scene.set_state(current_scene.ConnectState.ConnectionFailed)

# on_connected_to_server is called when joining (not hosting) successfully.
# @driven(signal)
# @impure
func on_connected_to_server():
	# send our configuration to the server
	rpc_id(1, "net_peer_configure", peer)

# on_server_disconnected is called when the connection to the server is lost.
# @driven(signal)
# @impure
func on_server_disconnected():
	# stop game
	stop_game(false)
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
		# send to other peers the disconnected peer id
		rpc("net_peer_disconnected", peer_id)
		# removes the peer from the peers list
		net_peer_disconnected(peer_id)

# net_peer_configure is called on the server when a new peer sends its config.
# @driven(client_to_server)
# @impure
master func net_peer_configure(new_peer):
	# check if rpc sender id match peer config
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != new_peer.id:
		print("net_peer_configure(): warning: peer id mismatch")
		get_tree().get_network_peer().disconnect_peer(get_tree().get_rpc_sender_id())
		return
	# compute new peer name (avoid dups)
	new_peer.name = get_peer_name(new_peer.name)
	# compute new peer index
	new_peer.index = get_next_peer_index()
	# force the peer not to be ready
	new_peer.ready = false
	# tell the peer he is configured
	rpc_id(new_peer.id, "net_peer_configured", new_peer)
	# if the server is playing, send its info too to the new peer
	if current_listen_server:
		rpc_id(new_peer.id, "net_peer_configured", peer)
	# send new peer info to the other connected peers and the other way around
	for other_peer_id in peers:
		rpc_id(other_peer_id, "net_peer_configured", new_peer)
		rpc_id(new_peer.id, "net_peer_configured", peers[other_peer_id])
	# add the new peer to the peers list
	net_peer_configured(new_peer)

# net_peer_configured is called when the server tells us the given peer is correctly configured.
# @driven(server_to_client)
# @impure
remote func net_peer_configured(other_peer):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_configured(): warning sender is not server")
	if other_peer.id == peer.id:
		# save our config
		peer = other_peer
		# go to lobby menu scene upon successful connection
		set_state(GameState.Lobby)
		goto_lobby_menu_scene()
	# add the configured peer to the peers
	peers[other_peer.id] = other_peer
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_peers(peers)
	print("net_peer_configured: ", other_peer)

# net_peer_post_configure is called on the server when a new peer sends its player_id / ready state.
# @driven(client_to_server)
# @impure
master func net_peer_post_configure(peer_id: int, peer_player_id: int, peer_ready: bool):
	# check if rpc sender id match peer config
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != peer_id:
		print("net_peer_post_configure(): warning: peer id mismatch")
		get_tree().get_network_peer().disconnect_peer(get_tree().get_rpc_sender_id())
		return
	# send other peers that the peer player_id / ready state changed
	rpc("net_peer_post_configured", peer_id, peer_player_id, peer_ready)
	# save the peer player_id / ready state
	net_peer_post_configured(peer_id, peer_player_id, peer_ready)

# net_peer_post_configured is called when the server tells us the given peer changed its player_id / ready state.
# @driven(server_to_client)
# @impure
remote func net_peer_post_configured(peer_id: int, peer_player_id: int, peer_ready: bool):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_post_configured(): warning sender is not server")
	# save the player_id ready state
	peers[peer_id].ready = peer_ready
	# save the player_id
	peers[peer_id].player_id = peer_player_id
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_peers(peers)

# net_other_peer_disconnected is called when the server tells us another peer has disconnected.
# @driven(server_to_client)
# @impure
remote func net_peer_disconnected(peer_id: int):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_disconnected(): warning sender is not server")
	# if our peer is disconnected, we got kicked
	if peer.id == peer_id:
		# connect error state
		set_state(GameState.ConnectError)
		# go to connect menu scene and ...
		goto_connect_menu_scene()
		# ... display kick message
		current_scene.set_state(current_scene.ConnectState.ConnectionKicked)
		return
	# remove the disconnected peer from the peers
	peers.erase(peer_id)
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_peers(peers)
	print("net_peer_disconnected: ", peer_id)

# get_peer_name returns the next peer name available.
# @pure
func get_peer_name(name: String) -> String:
	var unique = 1
	var restart = true
	var unique_name = name
	while restart:
		restart = false
		for other_peer_id in peers:
			if unique_name == peers[other_peer_id].name:
				unique += 1
				restart = true
				unique_name = name + str(unique)
	return unique_name

# get_next_peer_index returns the next peer index available.
# @pure
func get_next_peer_index() -> int:
	var index = 1 if current_listen_server else 0
	for other_peer_id in peers:
		var other_peer_index = peers[other_peer_id].index
		if index == other_peer_index:
			index += 1
	return index

# is_every_peer_ready returns true if every peer is ready.
# @pure
func is_every_peer_ready() -> bool:
	if peers.size() <= 1:
		return false
	for peer_id in peers:
		if not peers[peer_id].ready:
			return false
	return true