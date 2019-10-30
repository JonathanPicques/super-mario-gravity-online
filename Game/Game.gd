extends Control

enum GameState {
	None,
	Home,
	Lobby,
	Connecting,
	ConnectError,
	LoadGameMode,
	PlayGameMode,
	ResultScreen,
}

enum PeerState {
	None,
	Registered,
	PlayGameMode,
}

const Base = preload("res://Game/Maps/Base/Base.tscn")
const HomeMenu = preload("res://Game/Menus/HomeMenu.tscn")
const LobbyMenu = preload("res://Game/Menus/LobbyMenu.tscn")
const ConnectMenu = preload("res://Game/Menus/ConnectMenu.tscn")

const PlayerCamera = preload("res://Game/Players/Cam/PlayerCamera2D.tscn")

var MultiplayerHelper := preload("res://Game/MultiplayerHelper.gd").new()

var state = GameState.None
var current_ip := ""
var current_port := 0
var current_scene: Node
var current_max_peers := 0
var current_listen_server := false

# self peer
var peer := {
	id = 0,                 # peer network id
	name = "",              # peer name
	index = 0,              # peer index (order of connection)
	ready = false,          # peer ready
	state = PeerState.None, # peer state
	player_id = 0,          # peer player id (Mario = 0, Luigi = 1, ...)
	position_index = 0,     # peer position (1st, 2nd, ...)
	position_length = 0,    # peer distance from flag
}
# other peers dictionary (self peer is included)
# @key {int} peer id
# @value {Dictionary} peer info (@see self peer)
var peers := {}

# player skins available
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
	get_tree().connect("connection_failed", self, "on_connection_failed")
	get_tree().connect("server_disconnected", self, "on_server_disconnected")
	get_tree().connect("connected_to_server", self, "on_connected_to_server")
	get_tree().connect("network_peer_connected", self, "on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "on_network_peer_disconnected")
	# go to home menu scene
	set_state(GameState.Home)
	goto_home_menu_scene()
	# debug args to start server/client
	var argument = OS.get_cmdline_args()[0] if len(OS.get_cmdline_args()) > 0 else ""
	match argument:
		"--server": host_game(45678, 4)
		"--client": join_game("localhost", 45678)

# _process is called each tick.
# @driven(lifecycle)
# @impure
func _process(delta: float):
	MultiplayerHelper.poll()

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

func play_sound_effect(stream: AudioStream, volume_db = -20):
	$SoundEffects/SFX1.stream = stream
	$SoundEffects/SFX1.volume_db = volume_db
	$SoundEffects/SFX1.play()

# goto_home_menu loads the home menu.
# @impure
func goto_home_menu_scene():
	var home_menu_scene := HomeMenu.instance()
	home_menu_scene.connect("host_game", self, "host_game")
	home_menu_scene.connect("join_game", self, "join_game")
	set_scene(home_menu_scene)

# goto_home_menu loads the lobby menu.
# @impure
func goto_lobby_menu_scene():
	var lobby_menu_scene := LobbyMenu.instance()
	lobby_menu_scene.connect("stop_game", self, "stop_game")
	set_scene(lobby_menu_scene)

# goto_error_menu loads the error menu.
# @impure
func goto_connect_menu_scene():
	var error_menu_scene := ConnectMenu.instance()
	error_menu_scene.connect("stop_game", self, "stop_game")
	set_scene(error_menu_scene)

# host_game hosts a game as a (listen?) server on the given port with the given number of max peers.
# @impure
func host_game(port: int, max_peers: int, listen_server = true, peer_name: String = "server"):
	var mp_peer = MultiplayerHelper.create_server()
	current_port = port
	current_max_peers = max_peers
	current_listen_server = listen_server
	if MultiplayerHelper.host("", port, max_peers):
		get_tree().set_network_peer(mp_peer)
		peer.id = get_tree().get_network_unique_id()
		peer.name = peer_name
		net_peer_register(peer)
	else:
		set_state(GameState.ConnectError)
		goto_connect_menu_scene()
		current_scene.set_state(current_scene.ConnectState.HostingFailed)

# join_game joins a game on the given ip:port.
# @impure
func join_game(ip: String, port: int, peer_name: String = "client"):
	var mp_peer = MultiplayerHelper.create_client()
	current_ip = ip
	current_port = port
	if MultiplayerHelper.join(ip, port):
		peer.name = peer_name
		get_tree().set_network_peer(mp_peer)
		set_state(GameState.Connecting)
		goto_connect_menu_scene()
	else:
		set_state(GameState.ConnectError)
		goto_connect_menu_scene()
		current_scene.set_state(current_scene.ConnectState.ConnectionFailed)

# stop_game stops hosting or playing as a client.
# @impure
func stop_game(return_home: bool = true):
	var mp_peer := get_tree().get_network_peer()
	if mp_peer != null:
		# close connection
		MultiplayerHelper.close()
		# reset network peer
		get_tree().set_network_peer(null)
		# reset self peer values
		peer.id = 0
		peer.index = 0
		peer.ready = false
		peer.position_index = 0
		peer.position_length = 0
		# remove all other peers
		peers.clear()
	# return to home menu scene
	if return_home:
		set_state(GameState.Home)
		goto_home_menu_scene()

# on_connection_failed is called when joining the server failed.
# @driven(signal)
# @impure
func on_connection_failed():
	# on_connection_failed will sometime be called when the connection to the server is lost
	if MultiplayerHelper.was_connected:
		return on_server_disconnected()
	# stop game
	stop_game(false)
	# connect error state
	set_state(GameState.ConnectError)
	# load error menu scene
	goto_connect_menu_scene()
	# display connection failed error
	current_scene.set_state(current_scene.ConnectState.ConnectionFailed)

# on_server_disconnected is called when we lose connection to the server.
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

# on_connected_to_server is called when joining (not hosting) successfully.
# @driven(signal)
# @impure
func on_connected_to_server():
	# setup our peer
	peer.id = get_tree().get_network_unique_id()
	# register to the server
	rpc_id(1, "net_peer_register", peer)
	# tell the multiplayer helper that the connection was successful
	MultiplayerHelper.was_connected = true

# on_network_peer_connected is called when a peer is connected.
# @driven(signal)
# @impure
func on_network_peer_connected(peer_id: int):
	print("on_network_peer_connected: ", peer_id)
	pass

# on_network_peer_disconnected is called when a peer is disconnected.
# @driven(signal)
# @impure
func on_network_peer_disconnected(peer_id: int):
	if get_tree().is_network_server():
		# send to other peers the disconnected peer id
		rpc("net_peer_disconnected", peer_id)
		# removes the peer from the peers list
		net_peer_disconnected(peer_id)
		# remove the peer from the game mode if playing
		if state == GameState.PlayGameMode:
			current_scene.rpc("destroy_peer", peer_id)
			current_scene.destroy_peer(peer_id)

# net_peer_disconnected is called when the server tells us a peer has disconnected.
# @driven(server_to_client)
# @impure
remote func net_peer_disconnected(peer_id: int):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_disconnected(): warning sender is not server")
	# if our peer is disconnected, we got kicked
	if peer.id == peer_id:
		# stop game
		stop_game(false)
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

# net_peer_register is called on the server when a new peer registers for the first time.
# @driven(client_to_server)
# @impure
master func net_peer_register(new_peer):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != new_peer.id:
		print("net_peer_register(): warning: peer id mismatch")
		get_tree().get_network_peer().disconnect_peer(get_tree().get_rpc_sender_id())
		return
	# force peer id for clients
	new_peer.id = get_tree().get_rpc_sender_id() if not get_tree().is_network_server() else new_peer.id
	# compute new peer name (avoid dups)
	new_peer.name = get_peer_name(new_peer.name)
	# compute new peer index
	new_peer.index = get_next_peer_index()
	# force the peer not to be ready
	new_peer.ready = false
	# force the peer to be registered
	new_peer.state = PeerState.Registered
	# add the new peer to the server peers list
	net_peer_registered(new_peer)
	# tell the peers a new peer is registered
	rpc("net_peer_registered", new_peer)
	# send other peer config to the new peer
	for other_peer_id in peers:
		if other_peer_id == new_peer.id:
			continue
		rpc_id(new_peer.id, "net_peer_registered", peers[other_peer_id])

# net_peer_registered is called when the server tells us the given new peer is registered for the first time.
# @driven(server_to_client)
# @impure
remote func net_peer_registered(new_peer):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_registered(): warning sender is not server")
	# add the registered peer to the peers
	peers[new_peer.id] = new_peer
	# if this is our config, save it and go to lobby menu scene
	if new_peer.id == peer.id:
		peer = new_peer
		# go to lobby menu scene upon successful connection
		set_state(GameState.Lobby)
		goto_lobby_menu_scene()
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_peers(peers)
	print("net_peer_registered: ", new_peer)

# net_peer_lobby_update is called on the server when a new peer sends its player_id/ready state.
# @driven(client_to_server)
# @impure
master func net_peer_lobby_update(peer_id: int, peer_ready: bool, peer_player_id: int):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != peer_id:
		print("net_peer_lobby_update(): warning: peer id mismatch")
		get_tree().get_network_peer().disconnect_peer(get_tree().get_rpc_sender_id())
		return
	# update the peer
	peers[peer_id].ready = peer_ready
	peers[peer_id].player_id = peer_player_id
	# save the peer player_id/ready state
	net_peer_lobby_updated(peers[peer_id])
	# send peers that the peer player_id/ready state changed
	rpc("net_peer_lobby_updated", peers[peer_id])
	# if all peers are ready, start the game mode
	if state == GameState.Lobby and is_every_peer_ready():
		# load the game mode
		net_peer_start_game_mode("res://Game/Modes/Race/RaceGameMode.tscn")
		# tell peers to load the game mode
		rpc("net_peer_start_game_mode", "res://Game/Modes/Race/RaceGameMode.tscn")
		# start game mode with the given map
		current_scene.start("res://Game/Maps/Base/Base.tscn", peers)
		# tell peers to start the game mode with the given map
		current_scene.rpc("start", "res://Game/Maps/Base/Base.tscn", peers)

# net_peer_lobby_updated is called when the server tells us the given peer changed its player_id/ready state.
# @driven(server_to_client)
# @impure
remote func net_peer_lobby_updated(updated_peer):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_lobby_updated(): warning sender is not server")
	# save peer config
	if peer.id == updated_peer.id:
		peer = updated_peer
	peers[updated_peer.id] = updated_peer
	# update lobby
	if state == GameState.Lobby:
		current_scene.set_peers(peers)
	print("net_peer_lobby_updated: ", updated_peer)

# net_peer_start_game_mode is called when the server tells us to start the given game mode.
# @driven(server_to_client)
# @impure
remote func net_peer_start_game_mode(game_mode_path: String):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		return print("net_peer_start_game_mode(): warning sender is not server")
	set_state(GameState.LoadGameMode)
	var game_mode_scene = load(game_mode_path).instance()
	set_scene(game_mode_scene)
	set_state(GameState.PlayGameMode)
	print("net_peer_start_game_mode: ", game_mode_path)

# get_peer_name returns the next peer name available.
# @pure
func get_peer_name(name: String) -> String:
	var unique := 1
	var restart := true
	var unique_name := name
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
	var index := 0
	for other_peer_id in peers:
		var other_peer_index = peers[other_peer_id].index
		if index == other_peer_index:
			index += 1
	return index

# is_every_peer_ready returns true if every peer is ready.
# @pure
func is_every_peer_ready() -> bool:
	if peers.size() <= 0: # TODO
		return false
	for peer_id in peers:
		if not peers[peer_id].ready:
			return false
	return true