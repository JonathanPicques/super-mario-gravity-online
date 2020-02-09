extends Node
class_name MultiplayerManagerNode

enum PlayerTransformationType {
	Frog = 0,
	Prince = 1
}

onready var PlayerTransformations = {
	PlayerTransformationType.Frog: preload("res://Game/Players/Classes/Frog/Frog.tscn"),
	PlayerTransformationType.Prince: preload("res://Game/Players/Classes/Prince/Prince.tscn")
}

signal player_added(player)
signal player_removed(player)
signal player_set_skin(player, skin_id)
signal player_set_ready(player, ready)
signal player_set_peer_id(player, peer_id, local_id)
signal player_replaced_node(player, new_player_node, old_player_node)

signal online()
signal offline()

const MAX_PLAYERS := 4
const OP_CODE_WEBRTC := 1

enum SortPlayerMethods { normal, inverted, ranked, ranked_inverted }

# players
var players := []

# required properties for a player to be valid
var sample_player := {
	id = -1,
	name = "",
	local = true,
	ready = false,
	skin_id = 0,
	peer_id = -1,
	local_id = -1,
	input_device_id = -1,
	# race game mode
	rank = 0,
	rank_distance = 0.0,
}

var my_peer_id := -1
var my_session_id := ""
var next_available_peer_id := 1

var nakama_client = null
var matchmaker_ticket = null

var match_data := {}
var match_peers := {}

var webrtc_peers := {}
var webrtc_peers_ok := {}
var webrtc_multiplayer: WebRTCMultiplayer

# _ready connects to the matchmaking server.
# @impure
func _ready():
	init_nakama()

# _process polls new events from matchmaking.
# @impure
func _process(delta: float) -> void:
	if nakama_client:
		nakama_client.poll()

# _notification is called to check if the application is quitting to dispose of network resources.
# @impure
func _notification(event):
	if event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		finish_playing()

############
# Play API #
############

# @pure
func start_playing():
	pass

# @impure
func finish_playing():
	if nakama_client and match_data.has("match_id"):
		finish_match()
	if nakama_client and matchmaker_ticket:
		finish_matchmaking()
	if webrtc_multiplayer:
		finish_webrtc()
	for player in get_players(SortPlayerMethods.inverted):
		if not player.local:
			remove_player(player.id)
		else:
			player_set_ready(player.id, false)

##############
# Player API #
##############

# @impure
func add_player(name: String, local: bool, input_device_id: int = -1, peer_id: int = -1, local_id: int = -1) -> Dictionary:
	var id = get_next_player_id()
	var player = sample_player.duplicate(true)
	player.id = id
	player.name = name
	player.local = local
	player.peer_id = peer_id
	player.local_id = local_id
	player.input_device_id = input_device_id
	players.append(player)
	emit_signal("player_added", player)
	return player

# @impure
func remove_player(player_id: int) -> Dictionary:
	var player = get_player(player_id)
	emit_signal("player_removed", player)
	players.erase(player)
	return player

# @impure
func player_set_skin(player_id: int, skin_id: int) -> void:
	var player = get_player(player_id)
	player.skin_id = skin_id
	emit_signal("player_set_skin", player, skin_id)

# @impure
func player_set_ready(player_id: int, ready: bool) -> void:
	var player = get_player(player_id)
	player.ready = ready
	emit_signal("player_set_ready", player, ready)

# @impure
func player_set_peer_id(player_id: int, peer_id: int, local_id: int):
	var player = get_player(player_id)
	player.peer_id = peer_id
	player.local_id = local_id
	emit_signal("player_set_peer_id", player, peer_id, local_id)

# @pure
func get_player(player_id: int):
	for player in players:
		if player.id == player_id:
			return player
	return null

# @pure
func get_players(sort_method := SortPlayerMethods.normal) -> Array:
	match sort_method:
		SortPlayerMethods.ranked:
			var ranked_players := players.duplicate()
			ranked_players.sort_custom(self, "player_sort_by_rank")
			return ranked_players
		SortPlayerMethods.inverted:
			var inverted_players := players.duplicate()
			inverted_players.invert()
			return inverted_players
		SortPlayerMethods.ranked_inverted:
			var ranked_inverted_players := players.duplicate()
			ranked_inverted_players.sort_custom(self, "player_sort_by_rank")
			ranked_inverted_players.invert()
			return ranked_inverted_players
		_:
			return players.duplicate()

# @pure
func get_lead_player():
	return players[0] if players.size() > 0 else null
	
# @pure
func get_closest_player(player_id: int): # FIXME: shouldn't pass the ID 
	var index := 0
	var ranked_players := get_players(SortPlayerMethods.ranked)
	print("ranked_players: ", ranked_players)
	for player in ranked_players:
		if player.id == player_id and index - 1 >= 0:
			return ranked_players[index - 1]
		index += 1
	return null

# @pure
func is_local_player(player_id: int) -> bool:
	return players[player_id].local

# @pure
func get_local_player_count() -> int:
	var count := 0
	for player in players:
		if player.local:
			count += 1
	return count

# @pure
func get_next_player_id() -> int:
	var restart := true
	var player_id := 0
	while restart:
		restart = false
		for player in players:
			if player_id == player.id:
				player_id += 1
				restart = true
	return player_id

# @pure
func get_next_player_local_id(peer_id: int) -> int:
	var restart := true
	var local_id := 0
	while restart:
		restart = false
		for player in players:
			if peer_id == player.peer_id and local_id == player.local_id:
				local_id += 1
				restart = true
	return local_id

# @pure
func has_server_authority() -> bool:
	return get_local_player_count() == players.size() or get_tree().is_network_server()

# @pure
func is_every_player_ready() -> bool:
	if players.empty():
		return false
	for player in players:
		if not player.ready:
			return false
	return true

# @pure
func has_room_for_new_player() -> bool:
	return players.size() < MAX_PLAYERS

# @pure
func player_sort_by_rank(player_a: Dictionary, player_b: Dictionary) -> int:
	return player_a.rank < player_b.rank 

###################
# Player node API #
###################

# @pure
func get_player_node(player_id: int):
	var player_node_name = get_player_node_name(player_id)
	if not player_node_name:
		return null
	return Game.map_node.PlayerSlot.get_node(get_player_node_name(player_id))

# @pure
func get_player_node_name(player_id: int):
	var player = get_player(player_id)
	if not player:
		return null
	return "player_%d_%d" % [player.peer_id, player.local_id] # peer_id and local_id are the same on all peers

# @impure
func create_player_node(player: Dictionary, player_transformation: int = 0) -> PlayerNode:
	var player_node: PlayerNode = PlayerTransformations[player_transformation].instance()
	player_node.name = get_player_node_name(player.id)
	player_node.player = player
	player_node.set_network_master(player.peer_id)
	return player_node

# @impure
func spawn_player_node(player: Dictionary, player_transformation: int = 0) -> PlayerNode:
	var player_node := create_player_node(player, player_transformation)
	Game.map_node.PlayerSlot.add_child(player_node)
	return player_node

# @impure
func spawn_player_nodes():
	for player in players:
		spawn_player_node(player)

# @async
# @impure
func replace_player_node(player: Dictionary, new_player_node: PlayerNode) -> PlayerNode:
	var old_player_node: PlayerNode = get_player_node(player.id)
	new_player_node.name = old_player_node.name
	new_player_node.player = old_player_node.player
	new_player_node.position = old_player_node.position
	new_player_node.velocity = old_player_node.velocity
	yield(get_tree(), "idle_frame")
	Game.map_node.PlayerSlot.remove_child(old_player_node)
	Game.map_node.PlayerSlot.add_child(new_player_node)
	emit_signal("player_replaced_node", player, new_player_node, old_player_node)
	return new_player_node

##########
# Nakama #
##########

# @pure
func is_online():
	return nakama_client != null

# @impure
func init_nakama():
	var unique_id := String(OS.get_unix_time())
	var promise = $NakamaRestClient.authenticate_device(unique_id, true)
	if promise.error == OK:
		yield(promise, "completed")
	print("init_nakama: authenticate_device")
	promise = $NakamaRestClient.get_account()
	if promise.error == OK:
		yield(promise, "completed")
	print("init_nakama: get_account")
	nakama_client = $NakamaRestClient.create_realtime_client()
	if not nakama_client:
		print("init_nakama: ko")
		return
	nakama_client.connect("error", self, "on_nakama_client_error")
	nakama_client.connect("disconnected", self, "on_nakama_client_disconnected")
	nakama_client.connect("match_data", self, "on_match_data")
	nakama_client.connect("match_presence", self, "on_match_presence")
	nakama_client.connect("matchmaker_matched", self, "on_matchmaking_matched")
	yield(nakama_client, "connected")
	print("init_nakama: ok")
	emit_signal("online")

# @impure
func on_nakama_client_error(error: Dictionary):
	print("on_nakama_client_error: ", error)
	nakama_client = null
	emit_signal("offline")

# @impure
func on_nakama_client_disconnected(data: Dictionary):
	print("on_nakama_client_disconnected: ", data)
	nakama_client = null
	emit_signal("offline")

###############
# Matchmaking #
###############

# @impure
func start_matchmaking():
	var player_count := players.size()
	for player_preferred_count in range(MAX_PLAYERS - player_count, 0, -1):
		# try to query the preferred player count
		var query := "+properties.player_count:%d" % player_preferred_count
		# send a matchmaking request to nakama
		var promise = nakama_client.send({ matchmaker_add = {
			query = query,
			min_count = 2,
			max_count = 4,
			string_properties = {
				players = JSON.print(players),
			},
			numeric_properties = {
				player_count = player_count
			}
		} })
		# read response from nakama
		if promise.error == OK:
			print("start_matchmaking: %s" % query)
			promise.connect("completed", self, "on_matchmaking_add")
		else:
			finish_matchmaking()
		# if there is no match found after a while, retry with lower expectations
		if player_preferred_count > 1:
			# wait a bit before restarting matchmaking
			yield(get_tree().create_timer(1), "timeout")
			# if the matchmaker ticket is consumed, we successfully found a match
			if not matchmaker_ticket:
				return
			# otherwise restart matchmaking with lower expectations
			yield(finish_matchmaking(), "completed")

# @impure
func finish_matchmaking():
	if not matchmaker_ticket:
		print("finish_matchmaking: warning no matchmaking in progress")
		return
	var promise = nakama_client.send({ matchmaker_remove = { ticket = matchmaker_ticket } })
	if promise.error == OK:
		matchmaker_ticket = null
		yield(promise, "completed")
	print("finish_matchmaking: ok")

# @impure
func on_matchmaking_add(data: Dictionary, request: Dictionary):
	if data.has("matchmaker_ticket"):
		matchmaker_ticket = data["matchmaker_ticket"]["ticket"]

# @impure
func on_matchmaking_matched(data: Dictionary):
	if data.has("self") && data.has("token") && data.has("users"):
		my_session_id = data["self"]["presence"]["session_id"]
		for match_peer in data["users"]:
			match_peers[match_peer["presence"]["session_id"]] = match_peer["presence"]
			match_peers[match_peer["presence"]["session_id"]]["players"] = JSON.parse(match_peer["string_properties"]["players"]).result
		var session_ids := match_peers.keys()
		session_ids.sort()
		for session_id in session_ids:
			match_peers[session_id]["peer_id"] = next_available_peer_id
			if session_id == my_session_id:
				my_peer_id = match_peers[session_id]["peer_id"]
			next_available_peer_id += 1
		nakama_client.send({ match_join = {token = data["token"]}}).connect("completed", self, "on_match_join")
		matchmaker_ticket = null

#####################
# Multiplayer Match #
#####################

# @impure
func finish_match():
	if not match_data.has("match_id"):
		print("finish_match: warning no match in progress")
	nakama_client.send({ match_leave = { match_id = match_data["match_id"] }})
	match_data.clear()
	match_peers.clear()
	my_session_id = ""

# @impure
func on_match_join(data: Dictionary, request: Dictionary):
	if data.has("match"):
		init_webrtc()
		match_data = data["match"]
		my_session_id = match_data["self"]["session_id"]
		for match_peer in match_data["presences"]:
			if match_peer["session_id"] == my_session_id:
				continue
			connect_webrtc_peer(match_peers[match_peer["session_id"]])

# @impure
func on_match_data(data: Dictionary):
	var json = JSON.parse(data["data"])
	var content = json.result
	match data["op_code"]:
		OP_CODE_WEBRTC:
			if content["target"] == my_session_id:
				var session_id = data["presence"]["session_id"]
				var webrtc_peer = webrtc_peers[session_id]
				match content["method"]:
					"reconnect":
						webrtc_multiplayer.remove_peer(match_peers[session_id]["peer_id"])
						reconnect_webrtc_peer(match_peers[session_id])
					"add_ice_candidate":
						webrtc_peer.add_ice_candidate(content["media"], content["index"], content["name"])
					"set_remote_description":
						webrtc_peer.set_remote_description(content["type"], content["sdp"])

# @impure
func on_match_presence(data: Dictionary):
	if data.has("joins"):
		for join_match_peer in data["joins"]:
			if join_match_peer["session_id"] != my_session_id:
				connect_webrtc_peer(match_peers[join_match_peer["session_id"]])
	if data.has("leaves"):
		for leave_match_peer in data["leaves"]:
			if leave_match_peer["session_id"] != my_session_id:
				var match_peer = match_peers[leave_match_peer["session_id"]]
				disconnect_webrtc_peer(match_peer)
				for player in get_players(SortPlayerMethods.inverted):
					if player.peer_id == match_peer["peer_id"]:
						remove_player(player.id)

######################
# Multiplayer WebRTC #
######################

# @impure
func init_webrtc():
	if webrtc_multiplayer:
		print("init_webrtc: warning webrtc already in progress")
	webrtc_multiplayer = WebRTCMultiplayer.new()
	webrtc_multiplayer.connect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.connect("peer_disconnected", self, "on_webrtc_peer_disconnected")
	webrtc_multiplayer.initialize(match_peers[my_session_id]["peer_id"])
	get_tree().set_network_peer(webrtc_multiplayer)

# @impure
func finish_webrtc():
	if not webrtc_multiplayer:
		print("finish_webrtc: warning no webrtc in progress")
	webrtc_peers.clear()
	webrtc_peers_ok.clear()
	my_peer_id = -1
	next_available_peer_id = 1
	webrtc_multiplayer.close()
	webrtc_multiplayer.disconnect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.disconnect("peer_disconnected", self, "on_webrtc_peer_disconnected")
	webrtc_multiplayer = null
	get_tree().set_network_peer(null)

# @impure
func connect_webrtc_peer(match_peer: Dictionary):
	if webrtc_peers.has(match_peer["session_id"]):
		return
	var webrtc_peer := WebRTCPeerConnection.new()
	webrtc_peer.initialize({
		"iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }]
	})
	webrtc_peer.connect("ice_candidate_created", self, "on_webrtc_peer_ice_candidate_created", [match_peer["session_id"]])
	webrtc_peer.connect("session_description_created", self, "on_webrtc_peer_session_description_created", [match_peer["session_id"]])
	webrtc_peers[match_peer["session_id"]] = webrtc_peer
	webrtc_multiplayer.add_peer(webrtc_peer, match_peer["peer_id"])
	if my_session_id.casecmp_to(match_peer["session_id"]) < 0:
		var result = webrtc_peer.create_offer()
		if result != OK:
			print("connect_webrtc_peer: warning unable to create webrtc offer")

# @impure
func reconnect_webrtc_peer(match_peer: Dictionary):
	var webrtc_peer = webrtc_peers[match_peer["session_id"]]
	webrtc_peer.close()
	webrtc_peers.erase(match_peer["session_id"])
	webrtc_peers_ok.erase(match_peer["session_id"])
	connect_webrtc_peer(match_peer)

# @impure
func disconnect_webrtc_peer(match_peer: Dictionary):
	var webrtc_peer = webrtc_peers[match_peer["session_id"]]
	webrtc_peer.close()
	webrtc_peers.erase(match_peer["session_id"])
	webrtc_peers_ok.erase(match_peer["session_id"])

# @impure
func on_webrtc_peer_connected(peer_id: int):
	print("on_webrtc_peer_connected: ", peer_id)
	for session_id in match_peers:
		var match_peer = match_peers[session_id]
		if match_peer["peer_id"] == peer_id:
			webrtc_peers_ok[session_id] = true
			var peer_local_id := 0
			for match_peer_player in match_peer["players"]:
				var player := add_player("Network Peer", false, -1, peer_id, peer_local_id)
				player_set_skin(player.id, match_peer_player.skin_id)
				player_set_ready(player.id, match_peer_player.ready)
				peer_local_id += 1
	for player in players:
		if player.local:
			player_set_peer_id(player.id, my_peer_id, player.local_id)
	for player in players:
		print("player %d joined (local: %s) (peer_id: %s) (local_id: %s)" % [player.id, player.local, player.peer_id, player.local_id])
	yield(get_tree().create_timer(3.0), "timeout")
	return Game.goto_game_mode_scene("res://Game/Modes/Race/RaceGameMode.tscn", { map = "res://Game/Maps/RainbowGarden.tscn" })

# @impure
func on_webrtc_peer_disconnected(peer_id: int):
	print("on_webrtc_peer_disconnected: ", peer_id)
	for session_id in match_peers:
		if match_peers[session_id]["peer_id"] == peer_id:
			if my_session_id.casecmp_to(session_id) < 0:
				nakama_client.send({
					match_data_send = {
						op_code = OP_CODE_WEBRTC,
						match_id = match_data["match_id"],
						data = JSON.print({
							method = "reconnect",
							target = session_id,
						}),
					},
				})
				reconnect_webrtc_peer(match_peers[session_id])

# @impure
func on_webrtc_peer_ice_candidate_created(media: String, index: int, name: String, session_id: String):
	nakama_client.send({
		match_data_send = {
			op_code = OP_CODE_WEBRTC,
			match_id = match_data["match_id"],
			data = JSON.print({
				name = name,
				index = index,
				media = media,
				target = session_id,
				method = "add_ice_candidate",
			}),
		},
	})

# @impure
func on_webrtc_peer_session_description_created(type: String, sdp: String, session_id: String):
	var webrtc_peer = webrtc_peers[session_id]
	webrtc_peer.set_local_description(type, sdp)
	nakama_client.send({
		match_data_send = {
			op_code = OP_CODE_WEBRTC,
			match_id = match_data["match_id"],
			data = JSON.print({
				sdp = sdp,
				type = type,
				target = session_id,
				method = "set_remote_description",
			}),
		},
	})
