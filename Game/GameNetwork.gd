extends Control
onready var MultiplayerHelper := preload("res://Game/MultiplayerHelper.gd").new()

enum StopError { none, hosting_failed, joining_failed, connection_lost, connection_failed }
enum PeerState { none, registered, loading_game_mode, done_loading_game_mode, playing_game_mode }

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

signal host # ()
signal stop # ()

signal registered # ()
signal selected_player # ()

signal server_load_game_mode # ()
signal client_load_game_mode # (game_mode_path: String, game_mode_options: Dictionary)
signal server_start_game_mode # ()
signal client_start_game_mode # ()

signal peer_registered # (peer_info: Dictionary)
signal peer_disconnected # (peer_id: int)
signal peer_selected_player # (peer_info: Dictionary)

# _ready is called when the game network node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("network_peer_connected", self, "_on_network_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")

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
			self_peer.index = 0
			self_peer.state = PeerState.registered
			self_peer.player_id = 0
			self_peer.player_ranking = -1
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
	# reset other peers
	other_peers.clear()
	# emit signal stop (to return to the home menu or display error)
	emit_signal("stop", error)

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

# _on_connected_to_server is called when connected to a server.
# @driven(signal)
# @impure
func _on_connected_to_server():
	# save our peer id
	self_peer.id = get_tree().get_network_unique_id()
	# rpc_id call net_peer_register to tell the server we want to register
	rpc_id(1, "net_register", self_peer)
	# tell the multiplayer helper that the connection was successful
	MultiplayerHelper.was_connected = true

# _on_network_peer_connected is called when a peer connects to the server.
# @driven(signal)
# @impure
func _on_network_peer_connected(peer_id: int):
	pass

# _on_network_peer_disconnected is called when a peer disconnects from the server.
# @driven(signal)
# @impure
func _on_network_peer_disconnected(peer_id: int):
	# connection lost to the given peer
	if get_tree().is_network_server():
		net_disconnect(peer_id)

####################
# Server functions #
####################

# net_register is called on the server by a peer when he wants to register.
# @impure
master func net_register(peer_info: Dictionary):
	# debug
	print("net_register: peer_info(", peer_info,")")
	# enforce peer infos
	peer_info.id = get_real_rpc_sender_id()
	peer_info.name = compute_unique_peer_name(peer_info.name)
	peer_info.index = compute_next_peer_index()
	peer_info.state = PeerState.registered
	peer_info.player_id = 0
	peer_info.player_ranking = -1
	# add the peer ...
	other_peers[peer_info.id] = peer_info
	# ... and tell him we accepted his registration
	rpc_id(peer_info.id, "on_net_registered", peer_info)
	# tell everyone else we got a new registered peer
	for other_peer_id in other_peers:
		if other_peer_id != peer_info.id:
			rpc_id(other_peer_id, "on_net_peer_registered", peer_info)
	# tell to this peer all that we got a bunch of already registered peers
	var all_peers := get_all_peers()
	for other_peer_id in all_peers:
		if other_peer_id != peer_info.id and all_peers[other_peer_id].state >= PeerState.registered:
			rpc_id(peer_info.id, "on_net_peer_registered", all_peers[other_peer_id])
	# emit signal to update the lobby
	emit_signal("peer_registered", other_peers[peer_info.id])

# net_register is called on and by the server to disconnect the given peer.
# @impure
master func net_disconnect(peer_id: int):
	# checksum
	if not is_rpc_sender_server():
		return print("net_disconnect: can only be called on the server")
	# debug
	print("net_disconnect: peer_id(", peer_id, ")")
	# check if peer exists
	if other_peers.has(peer_id):
		# erase the peer
		other_peers.erase(peer_id)
		# tell the other peers a peer disconnected
		rpc("on_net_peer_disconnected", peer_id)
		# emit signal to update the lobby or destroy a playing peer
		emit_signal("peer_disconnected", peer_id)

# net_select_player is called on the server by a peer when he wants to change its player id or is ready.
# @impure
master func net_select_player(player_id: int, player_ready: bool):
	var peer_id := get_real_rpc_sender_id()
	# checksum
	if peer_id != self_peer.id and (not other_peers.has(peer_id) or other_peers[peer_id].state < PeerState.registered):
		return print("net_select_player: warning peer does not exist or is not registered")
	# debug
	print("net_select_player: peer_id(", peer_id, ") player_id(", player_id, ") player_ready(", player_ready, ")")
	# set peer player
	if peer_id == self_peer.id:
		# listen server peer
		self_peer.player_id = player_id
		self_peer.player_ready = player_ready
		# emit signal to update lobby
		emit_signal("selected_player")
	else:
		# other peer
		other_peers[peer_id].player_id = player_id
		other_peers[peer_id].player_ready = player_ready
		# tell the peer we accepted his new player id or ready state
		rpc_id(peer_id, "on_net_selected_player", other_peers[peer_id])
		# emit signal to update lobby
		emit_signal("peer_selected_player")
	# tell the other peers that this peer changed its player id or ready state
	for other_peer_id in other_peers:
		if other_peer_id != peer_id and other_peers[other_peer_id].state >= PeerState.registered:
			rpc_id(other_peer_id, "on_net_peer_selected_player", self_peer if peer_id == self_peer.id else other_peers[peer_id])
	# load a game mode if all peers are ready and we are not loading/done loading or playing a game mode
	if self_peer.state == PeerState.registered and is_every_peer_ready():
		self_peer.state = PeerState.loading_game_mode
		emit_signal("server_load_game_mode")

# net_load_game_mode is called on an by the server to tell the peers to load the given game mode after the server loaded it.
# @impure
master func net_load_game_mode(game_mode_path: String, game_mode_options: Dictionary):
	# debug
	print("net_load_game_mode: game_mode_path(", game_mode_path, ") game_mode_options(", game_mode_options, ")")
	# set our peer state to done loading
	if is_listen_server:
		self_peer.state = PeerState.done_loading_game_mode
	# tell all registered & ready peers to load the given game mode
	for peer_id in other_peers:
		if other_peers[peer_id].player_ready and other_peers[peer_id].state == PeerState.registered:
			other_peers[peer_id].state = PeerState.loading_game_mode
			rpc_id(peer_id, "on_net_load_game_mode", game_mode_path, game_mode_options)
	# special case where the server wants to play alone
	if len(other_peers) == 0:
		net_start_game_mode()

# net_load_game_mode is called on the server after a peer loaded the game mode.
# @impure
master func net_loaded_game_mode():
	var peer_id := get_real_rpc_sender_id()
	# checksum
	if not other_peers.has(peer_id) or other_peers[peer_id].state != PeerState.loading_game_mode:
		return print("net_loaded_game_mode: warning peer does not exist or is not loading a game mode")
	# debug
	print("net_loaded_game_mode: peer_id(", peer_id, ")")
	# save peer info
	other_peers[peer_id].state = PeerState.done_loading_game_mode
	# start the game if everyone has loaded the game mode
	if self_peer.state == PeerState.done_loading_game_mode and is_every_peer_loaded():
		net_start_game_mode()

# net_start_game_mode is called on and by the server to start the game mode.
# @impure
master func net_start_game_mode():
	# debug
	print("net_start_game_mode")
	# save peer info
	self_peer.state = PeerState.playing_game_mode
	# set other state peers to playing game mode
	for peer_id in other_peers:
		if other_peers[peer_id].state == PeerState.done_loading_game_mode:
			other_peers[peer_id].state = PeerState.playing_game_mode
	# emit signal to start the game mode
	emit_signal("server_start_game_mode")
	# tell other playing peers to start the game mode
	for peer_id in other_peers:
		if other_peers[peer_id].state == PeerState.playing_game_mode:
			rpc_id(peer_id, "on_net_start_game_mode")

####################
# Client self peer #
####################

# on_net_registered is called by the server when our registration is done.
# @impure
remote func on_net_registered(self_peer_info: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_registered: can only be called by the server")
	# debug
	print("on_net_registered: self_peer_info(", self_peer_info, ")")
	# save our infos
	self_peer = self_peer_info
	# emit signal to update lobby
	emit_signal("registered")

# on_net_selected_player is called by the server when we changed our player id or is ready.
# @impure
remote func on_net_selected_player(self_peer_info: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_selected_player: can only be called by the server")
	# debug
	print("on_net_selected_player: self_peer_info(", self_peer_info, ")")
	# save our infos
	self_peer = self_peer_info
	# emit signal to update lobby
	emit_signal("selected_player")

# on_net_load_game_mode is called by the server when we should load the given game mode.
# @impure
remote func on_net_load_game_mode(game_mode_path: String, game_mode_options: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_load_game_mode: can only be called by the server")
	# debug
	print("on_net_load_game_mode: game_mode_path(", game_mode_path, ") game_mode_options(", game_mode_options, ")")
	# emit signal to load thge given game mode
	emit_signal("client_load_game_mode", game_mode_path, game_mode_options)

# on_net_start_game_mode is called by the server when we should start the loaded game mode.
remote func on_net_start_game_mode():
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_start_game_mode: can only be called by the server")
	# debug
	print("on_net_start_game_mode")
	# emit signal to start the game mode
	emit_signal("client_start_game_mode")

######################
# Client other peers #
######################

# on_net_peer_registered is called by the server when another peer is registered.
# @impure
remote func on_net_peer_registered(peer_info: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_peer_registered: can only be called by the server")
	# debug
	print("on_net_peer_registered: peer_info(", peer_info, ")")
	# save peer info
	other_peers[peer_info.id] = peer_info
	# emit signal to update the lobby
	emit_signal("peer_registered", peer_info)

# on_net_peer_disconnected is called by the server when another peer is disconnected.
# @impure
remote func on_net_peer_disconnected(peer_id: int):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_peer_registered: can only be called by the server")
	# debug
	print("on_net_peer_disconnected: peer_id(", peer_id, ")")
	# erase the peer
	other_peers.erase(peer_id)
	# emit signal to update the lobby or destroy a playing peer
	emit_signal("peer_disconnected", peer_id)

# on_net_peer_registered is called by the server when another peer is registered.
# @impure
remote func on_net_peer_selected_player(peer_info: Dictionary):
	# checksum
	if not is_rpc_sender_server():
		return print("on_net_peer_selected_player: can only be called by the server")
	# debug
	print("on_net_peer_selected_player: peer_info(", peer_info, ")")
	# save peer info
	other_peers[peer_info.id] = peer_info
	# emit signal to update the lobby
	emit_signal("peer_selected_player")

####################
# Helper functions #
####################

# get_all_peers returns the map of all peers.
# @pure
func get_all_peers(min_state:= PeerState.none) -> Dictionary:
	var all_peers := other_peers.duplicate()
	var filtered_peers := {}
	if is_listen_server or not get_tree().is_network_server():
		all_peers[self_peer.id] = self_peer
	for peer_id in all_peers:
		if all_peers[peer_id].state >= min_state:
			filtered_peers[peer_id] = all_peers[peer_id]
	return filtered_peers

# is_every_peer_ready returns true if every peer is ready.
# @pure
func is_every_peer_ready() -> bool:
	var all_peers := get_all_peers(PeerState.registered)
	for peer_id in all_peers:
		var peer = all_peers[peer_id]
		if not peer.player_ready:
			return false
	return true

# is_every_peer_loaded returns true if every peer has loaded the game mode.
# @pure
func is_every_peer_loaded() -> bool:
	for peer_id in other_peers:
		if not other_peers[peer_id].state == PeerState.done_loading_game_mode:
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