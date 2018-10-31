extends Node2D

enum GameState {
	None,
	LoadMap,
	InGameMap,
	ResultScreen
}

# var state = GameState.None

var current_ip = ""
var current_port = 0
var current_max_players = 0
var current_listen_server = false

var self_player = {id = 0, index = 0, name = "root", skin = "mario"}
var other_players = {}

# _ready is called when the node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	# get_tree().connect("connection_failed", self, "on_connection_failed")
	get_tree().connect("connected_to_server", self, "on_connected_to_server")
	# get_tree().connect("server_disconnected", self, "on_server_disconnected")
	get_tree().connect("network_peer_connected", self, "on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "on_network_peer_disconnected")
	if host_game(45678, 4):
		print("hosting")
	else:
		if join_game("127.0.0.1", 45678):
			print("joining")

# host_game hosts a game on the given port with the given number of max players.
# @param(int) port
# @param(int) max_players
# @param(boolean) listen_server
# @returns(bool)
# @impure
func host_game(port, max_players, listen_server = true):
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_server(port, max_players) == 0:
		current_port = port
		current_max_players = max_players
		current_listen_server = listen_server
		setup_self(peer)
		return true
	return false

# join_game joins a game on the given ip:port.
# @param(string) ip
# @param(int) port
# @impure
# @returns(bool)
func join_game(ip, port):
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_client(ip, port) == 0:
		current_ip = ip
		current_port = port
		setup_self(peer)
		return true
	return false

# stop_game stops hosting or playing as a client.
# @impure
func stop_game():
	var peer = get_tree().get_meta("network_peer")
	if peer != null:
		peer.close_connection()

# setup_self is called when successfully hosted or joined.
# @param(NetworkedMultiplayerPeer) peer
# @impure
func setup_self(peer):
	get_tree().set_network_peer(peer)
	get_tree().set_meta("network_peer", peer)
	self_player.id = get_tree().get_network_unique_id()

# on_connected_to_server is called when joining (not hosting) successfully.
# @driven(signal)
# @impure
func on_connected_to_server():
	# send our configuration to the server
	rpc_id(1, "net_player_configure", self_player)

# on_network_peer_connected is called when another peer is connected.
# @param(int) peer_id
# @driven(signal)
# @impure
func on_network_peer_connected(peer_id):
	pass

# on_network_peer_disconnected is called when another peer is disconnected.
# @param(int) peer_id
# @driven(signal)
# @impure
func on_network_peer_disconnected(peer_id):
	if get_tree().is_network_server():
		# send to other players the disconnected player id
		rpc("net_player_disconnected", peer_id)
		# removes the player from the players list
		net_player_disconnected(peer_id)

# net_player_configure is called on the server when a new player sends its config.
# @param(object) new_player_config
# @driven(client_to_server)
# @impure
master func net_player_configure(new_player_config):
	# check if rpc sender id match player config
	if get_tree().get_rpc_sender_id() != new_player_config.id:
		print("net_player_configure(): warning: player id mismatch")
		get_tree().get_network_peer().disconnect_peer(get_tree().get_rpc_sender_id())
		return
	# if the server is playing, send its info too to the new player
	if current_listen_server:
		rpc_id(new_player_config.id, "net_player_configured", self_player)
	# send new player info to the other connected players and the other way around
	for other_player_id in other_players:
		rpc_id(other_player_id, "net_player_configured", new_player_config)
		rpc_id(new_player_config.id, "net_player_configured", other_players[other_player_id])
	# tell the player he is configured
	rpc_id(new_player_config.id, "net_player_configured", new_player_config)
	# add the new player to the players list
	net_player_configured(new_player_config)

# net_other_player_configured is called when the server tells us the given player is correctly configured.
# @driven(server_to_client)
# @impure
remote func net_player_configured(player_config):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		print("net_other_player_configured(): warning sender is not server")
		return
	if player_config.id == self_player.id:
		self_player = player_config
	else:
		other_players[player_config.id] = player_config

# net_other_player_disconnected is called when the server tells us another player has disconnected.
# @driven(server_to_client)
# @impure
remote func net_player_disconnected(player_id):
	if not get_tree().is_network_server() and get_tree().get_rpc_sender_id() != 1:
		print("net_other_player_disconnected(): warning sender is not server")
		return
	if self_player.id == player_id:
		# we got ourselves kicked...
		pass
	other_players.erase(player_id)