extends Control
onready var MultiplayerHelper := preload("res://Game/MultiplayerHelper.gd").new()

enum PeerState { none, registered }
enum StopError { none, hosting_failed, joining_failed, connection_lost, connection_failed}

var self_peer := {
	id = -1,                 # peer unique id
	name = "",               # peer unique name
	index = -1,              # peer connection index (order of connection)
	state = PeerState.none,  # peer state
	#
	player_id = -1,          # peer player id (Mario = 0, Luigi = 1, ..)
	player_ready = false,    # peer player is ready to play
	player_ranking = -1,     # peer player ranking (1st, 2nd, ..)
}
var other_peers := {}
var is_listen_server := false

signal peer_register # (peer_id: int, peer_info: Dictionary)
signal peer_unregister # (peer_id: int)
signal peer_select_player # (peer_id: int, ready: bool, player_id: int)
signal peer_load_game_mode # (peer_id: int, game_mode_scene: Scene)
signal peer_start_game_mode # (peer_id: int)

signal host # ()
signal stop # ()

# _ready is called when the game network node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")

###################
# Network signals #
###################

# _on_connection_failed is called when failing to join a server.
# @driven(signal)
# @impure
func _on_connection_failed():
	# on_connection_failed will sometimes be called when the connection to the server is lost when using websockets
	if MultiplayerHelper.was_connected:
		return net_stop(StopError.connection_lost)
	# stop game
	net_stop(StopError.connection_failed)

# _on_connection_failed is called when the connection to the server is lost.
# @driven(signal)
# @impure
func _on_server_disconnected():
	# stop game
	net_stop(StopError.connection_lost)

# _on_connected_to_server is called when successfully joining a server.
# @driven(signal)
# @impure
func _on_connected_to_server():
	# save our peer id
	self_peer.id = get_tree().get_network_unique_id()
	# rpc_id call net_peer_register to tell the server we want to register
	rpc_id(1, "net_peer_register", self_peer)
	# tell the multiplayer helper that the connection was successful
	MultiplayerHelper.was_connected = true

# @driven(signal)
# @impure
func _on_network_peer_connected(peer_id: int):
	pass

# @driven(signal)
# @impure
func _on_network_peer_disconnected(peer_id: int):
	# unregister the given peer
	net_peer_unregister(peer_id)

###########################
# Host / Join / Stop APIs #
###########################

# net_host hosts a server on the given port.
# @impure
func net_host(addr: String, port: int, peer_name:= ""):
	var network_peer := MultiplayerHelper.create_server()
	if MultiplayerHelper.host(addr, port):
		# save network peer
		get_tree().set_network_peer(network_peer)
		# if peer name is not an empty string, start as a listen server
		is_listen_server = peer_name != ""
		# create a peer for the server
		if is_listen_server:
			self_peer.id = 1
			self_peer.name = peer_name
			call_deferred("net_peer_register", self_peer)
		# emit signal host (to go to lobby scene)
		emit_signal("host")
		# server started
		print("server started")
		return true
	# server failed to start
	net_stop(StopError.hosting_failed)
	return false

# join_game joins a game on the given ip:port.
# @impure
func net_join(addr: String, port: int, peer_name:= "client"):
	var network_peer := MultiplayerHelper.create_client()
	if MultiplayerHelper.join(addr, port):
		# save network peer
		get_tree().set_network_peer(network_peer)
		# save peer name (id will only be set if connection is successful)
		self_peer.name = peer_name
		# client started
		print("client started")
		return true
	# client failed to start
	net_stop(StopError.joining_failed)
	return false

# stop_game stops hosting or playing as a client, can happen on error.
# @impure
func net_stop(error:= StopError.none):
	if get_tree().get_network_peer() != null:
		print("server" if MultiplayerHelper.server else "client", " stopped")
		# close connection
		MultiplayerHelper.close()
		# reset network peer
		get_tree().set_network_peer(null)
	# reset self peer
	self_peer.id = -1
	self_peer.name = ""
	self_peer.index = -1
	# emit signal stop (to return to the home menu or display error)
	emit_signal("stop", error)

####################
# Server functions #
####################

# net_peer_register is called on the server when a peer wants to register.
# @impure
master func net_peer_register(peer_info: Dictionary):
	# enforce peer infos
	peer_info.id = get_real_rpc_sender_id()
	peer_info.name = compute_unique_peer_name(peer_info.name)
	peer_info.index = compute_next_peer_index()
	peer_info.state = PeerState.registered
	peer_info.player_id = 0
	peer_info.player_ranking = -1
	# register the peer
	on_net_peer_register(peer_info.id, peer_info)
	# let every other peer know that a new peer registers
	rpc("on_net_peer_register", peer_info.id, peer_info)
	# let know to the registering peer that the listen server is a peer
	if is_listen_server and peer_info.id != 1:
		rpc_id(peer_info.id, "on_net_peer_register", self_peer.id, self_peer)
	# let know to the registering peer every other registered peer
	for other_peer_id in other_peers:
		if other_peer_id != peer_info.id:
			rpc_id(peer_info.id, "on_net_peer_register", other_peer_id, other_peers[other_peer_id])

# net_peer_unregister is called on the server when the given peer wants to unregister or is disconnected.
# @impure
master func net_peer_unregister(peer_id: int):
	if other_peers.has(peer_id):
		var peer_info = other_peers[peer_id]
		# unregister the peer
		on_net_peer_unregister(peer_id, peer_info)
		# let every other peer know that this peer unregisters
		rpc("on_net_peer_unregister", peer_id, peer_info)

# net_peer_select_player is called on the server when a peer wants to select its player or is ready
# @impure
master func net_peer_select_player(player_id: int, player_ready: bool):
	# select or ready the peer player
	on_net_peer_select_player(get_real_rpc_sender_id(), player_id, player_ready)
	# let every other peer know that this peers selects its player or is ready
	rpc("on_net_peer_select_player", get_real_rpc_sender_id(), player_id, player_ready)

################################################
# Client / listen server as a client functions #
################################################

# on_net_peer_register is called by the server when the given peer registers.
# @impure
remote func on_net_peer_register(peer_id: int, peer_info: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_peer_register(): warning sender is not server")
	# store peer_info
	if peer_id == self_peer.id:
		self_peer = peer_info
	else:
		other_peers[peer_id] = peer_info
	# emit peer_registered signal (to update the lobby)
	print("peer_register: peer_id(", peer_id, ") peer_name(", peer_info.name, ") peer_index(", peer_info.index , ")")
	emit_signal("peer_register", peer_id, peer_info)

# on_net_peer_unregister is called by the server when the given peer disconnects/unregisters.
# @impure
remote func on_net_peer_unregister(peer_id: int, peer_info: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_peer_unregister(): warning sender is not server")
	# remove the peer
	other_peers.erase(peer_id)
	# emit peer_unregistered signal (to update the lobby)
	print("peer_unregister: peer_id(", peer_id, ")")
	emit_signal("peer_unregister", peer_id, peer_info)

# on_net_peer_select_player is called by the server when the given peer selects its player or is ready
# @impure
remote func on_net_peer_select_player(peer_id: int, player_id: int, player_ready: bool):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_peer_select_player(): warning sender is not server")
	# store peer player infos
	if peer_id == self_peer.id:
		self_peer.player_id = player_id
		self_peer.player_ready = player_ready
	else:
		other_peers[peer_id].player_id = player_id
		other_peers[peer_id].player_ready = player_ready
	# emit peer_select_player signal (to update the lobby)
	print("peer_select_player: peer_id(", peer_id, ") player_id(", player_id, ") player_ready(", player_ready, ")")
	emit_signal("peer_select_player", peer_id, player_id, player_ready)

####################
# Helper functions #
####################

# get_all_peers returns the map of all peers.
# @pure
func get_all_peers() -> Dictionary:
	var all_peers := other_peers.duplicate()
	if is_listen_server or not get_tree().is_network_server():
		all_peers[self_peer.id] = self_peer
	return all_peers

# is_every_peer_ready returns true if every peer is ready.
# @pure
func is_every_peer_ready() -> bool:
	var all_peers := get_all_peers()
	for peer_id in all_peers:
		if not all_peers[peer_id].player_ready:
			return false
	return true

# is_rpc_sender_server returns true if the sender is the server.
# @pure
func is_rpc_sender_server() -> bool:
	return get_tree().is_network_server() or get_tree().get_rpc_sender_id() == 1

# get_real_rpc_sender_id returns the rpc sender id, or 1 if called directly on the server.
# @pure
func get_real_rpc_sender_id() -> int:
	return 1 if get_tree().get_rpc_sender_id() == 0 else get_tree().get_rpc_sender_id()

# compute_next_peer_index returns the next peer index available.
# @pure
func compute_next_peer_index() -> int:
	var index := 0
	var restart := true
	var all_peers := get_all_peers()
	while restart:
		restart = false
		for peer_id in all_peers:
			var peer_index = all_peers[peer_id].index
			if index == peer_index:
				index += 1
				restart = true
	return index

# compute_unique_peer_name returns the next peer unique name available.
# @pure
func compute_unique_peer_name(name: String) -> String:
	var unique := 1
	var restart := true
	var all_peers := get_all_peers()
	var unique_name := name
	while restart:
		restart = false
		for peer_id in all_peers:
			if peer_id != self_peer.id and unique_name == all_peers[peer_id].name:
				unique += 1
				restart = true
				unique_name = name + str(unique)
	return unique_name