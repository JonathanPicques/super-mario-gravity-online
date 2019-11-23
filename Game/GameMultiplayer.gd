extends Node
class_name GameMultiplayerNode

signal player_add(player)
signal player_remove(player)
signal player_set_skin(player, skin_id)
signal player_set_ready(player, ready)

signal online()
signal offline()

const MAX_PLAYERS := 4
const OP_CODE_WEBRTC := 1

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
	peer_player_id = -1,
	input_device_id = -1,
	# race game mode
	rank = 0,
	rank_distance = 0.0,
}

var my_peer_id := -1
var my_session_id = null
var next_available_peer_id := 1

var nakama_client = null
var matchmaker_ticket = null

var match_data := {}
var match_peers := {}

var webrtc_peers := {}
var webrtc_peers_ok := {}
var webrtc_multiplayer: WebRTCMultiplayer

# _ready connects to the matchmaking server.
# @driven(lifecycle)
# @impure
func _ready():
	nakama_init()

# _process polls new events from matchmaking.
# @driven(lifecycle)
# @impure
func _process(delta: float) -> void:
	if nakama_client:
		nakama_client.poll()

# _notification is called to check if the application is quitting to dispose of network resources.
# @driven(lifecycle)
# @impure
func _notification(event):
	if event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		pass

##############
# Player API #
##############

# @impure
func add_player(name: String, local: bool, input_device_id: int = -1, peer_id: int = -1, peer_player_id: int = -1) -> Dictionary:
	var id = get_next_player_id()
	var player = sample_player.duplicate(true)
	player.id = id
	player.name = name
	player.local = local
	player.peer_id = peer_id
	player.peer_player_id = peer_player_id
	player.input_device_id = input_device_id
	players.append(player)
	emit_signal("player_add", player)
	return player

# @impure
func remove_player(player_id: int) -> Dictionary:
	var player = get_player(player_id)
	emit_signal("player_remove", player)
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

# @pure
func get_player(player_id: int):
	for player in players:
		if player.id == player_id:
			return player
	return null

# @pure
func get_players(invert := false):
	if not invert:
		return players
	var inverted_players := players.duplicate()
	inverted_players.invert()
	return inverted_players

# @pure
func get_lead_player():
	return players[0] if players.size() > 0 else null
	
# @pure
func get_closest_player(player_id: int): # FIXME: shouldn't pass the ID 
	for player in players:
		if player.id != player_id:
			return player
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
func get_next_peer_player_id(peer_id: int) -> int:
	var restart := true
	var peer_player_id := 0
	while restart:
		restart = false
		for player in players:
			if peer_id == player.peer_id and peer_player_id == player.peer_player_id:
				peer_player_id += 1
				restart = true
	return peer_player_id

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

###################
# Player node API #
###################

# @pure
func get_player_node(player_id: int) -> Node:
	return get_node("/root/Game").scene.MapSlot.get_node(get_player_node_name(player_id))

# @pure
func get_player_node_name(player_id: int) -> String:
	var player = players[player_id]
	return str(player.peer_id) + "_" + str(player.peer_player_id)

##########
# Nakama #
##########

# @pure
func is_online():
	return nakama_client != null

# @impure
func nakama_init():
	var unique_id := String(OS.get_unix_time())
	var promise = $NakamaRestClient.authenticate_device(unique_id, true)
	if promise.error == OK:
		yield(promise, "completed")
	print("nakama_init: authenticate_device")
	promise = $NakamaRestClient.get_account()
	if promise.error == OK:
		yield(promise, "completed")
	print("nakama_init: get_account")
	nakama_client = $NakamaRestClient.create_realtime_client()
	if not nakama_client:
		print("nakama_init: ko")
		return
	nakama_client.connect("error", self, "on_nakama_client_error")
	nakama_client.connect("disconnected", self, "on_nakama_client_disconnected")
	nakama_client.connect("match_data", self, "on_match_data")
	nakama_client.connect("match_presence", self, "on_match_presence")
	nakama_client.connect("matchmaker_matched", self, "on_matchmaking_matched")
	yield(nakama_client, "connected")
	print("nakama_init: ok")
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
func matchmaking_start():
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
			print("matchmaking_start: %s" % query)
			promise.connect("completed", self, "on_matchmaking_add")
		else:
			matchmaking_finish()
		# if there is no match found after a while, retry with lower expectations
		if player_preferred_count > 1:
			# wait a bit before restarting matchmaking
			yield(get_tree().create_timer(4), "timeout")
			# if the matchmaker ticket is consumed, we successfully found a match
			if not matchmaker_ticket:
				return
			# otherwise restart matchmaking with lower expectations
			yield(matchmaking_finish(), "completed")

# @impure
func matchmaking_finish():
	if not matchmaker_ticket:
		print("matchmaking_finish: warning no matchmaking in progress")
		return
	var promise = nakama_client.send({ matchmaker_remove = { ticket = matchmaker_ticket } })
	if promise.error == OK:
		yield(promise, "completed")
	print("matchmaking_finish: ok")

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
func on_match_join(data: Dictionary, request: Dictionary):
	if data.has("match"):
		webrtc_init()
		match_data = data["match"]
		my_session_id = match_data["self"]["session_id"]
		for match_peer in match_data["presences"]:
			if match_peer["session_id"] == my_session_id:
				continue
			webrtc_connect_peer(match_peers[match_peer["session_id"]])

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
						webrtc_reconnect_peer(match_peers[session_id])
					"add_ice_candidate":
						webrtc_peer.add_ice_candidate(content["media"], content["index"], content["name"])
					"set_remote_description":
						webrtc_peer.set_remote_description(content["type"], content["sdp"])

# @impure
func on_match_presence(data: Dictionary):
	if data.has("joins"):
		for join_match_peer in data["joins"]:
			if join_match_peer["session_id"] != my_session_id:
				webrtc_connect_peer(match_peers[join_match_peer["session_id"]])
	if data.has("leaves"):
		for leave_match_peer in data["leaves"]:
			if leave_match_peer["session_id"] != my_session_id:
				var match_peer = match_peers[leave_match_peer["session_id"]]
				webrtc_disconnect_peer(match_peer)
				for player in get_players(true):
					if player.peer_id == match_peer["peer_id"]:
						remove_player(player.id)

######################
# Multiplayer WebRTC #
######################

# @impure
func webrtc_init():
	webrtc_multiplayer = WebRTCMultiplayer.new()
	webrtc_multiplayer.connect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.connect("peer_disconnected", self, "on_webrtc_peer_disconnected")
	webrtc_multiplayer.initialize(match_peers[my_session_id]["peer_id"])
	get_tree().set_network_peer(webrtc_multiplayer)

# @impure
func webrtc_finish():
	webrtc_multiplayer.close()
	webrtc_multiplayer.disconnect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.disconnect("peer_disconnected", self, "on_webrtc_peer_disconnected")
	webrtc_multiplayer = null
	get_tree().set_network_peer(null)

# @impure
func webrtc_connect_peer(match_peer: Dictionary):
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
			print("webrtc_connect_peer: warning unable to create webrtc offer")

# @impure
func webrtc_reconnect_peer(match_peer: Dictionary):
	var webrtc_peer = webrtc_peers[match_peer["session_id"]]
	webrtc_peer.close()
	webrtc_peers.erase(match_peer["session_id"])
	webrtc_peers_ok.erase(match_peer["session_id"])
	webrtc_connect_peer(match_peer)

# @impure
func webrtc_disconnect_peer(match_peer: Dictionary):
	var webrtc_peer = webrtc_peers[match_peer["session_id"]]
	webrtc_peer.close()
	webrtc_peers.erase(match_peer["session_id"])
	webrtc_peers_ok.erase(match_peer["session_id"])

# @impure
func on_webrtc_peer_connected(peer_id: int):
	print("on_webrtc_peer_connected: ", peer_id)
	if true: # webrtc_peers_ok.size() == players.size() - 1:
		for session_id in match_peers:
			var match_peer = match_peers[session_id]
			if match_peer["peer_id"] == peer_id:
				webrtc_peers_ok[session_id] = true
				var peer_player_id := 0
				for match_peer_player in match_peer["players"]:
					var player := add_player("Network Peer", false, -1, peer_id, peer_player_id)
					player_set_skin(player.id, match_peer_player.skin_id)
					player_set_ready(player.id, match_peer_player.ready)
					peer_player_id += 1
		for player in players:
			if player.local:
				player.peer_id = my_peer_id
				player.peer_player_id = player.id
		var game_mode_node = load("res://Game/Modes/Race/RaceGameMode.tscn").instance()
		game_mode_node.options = { map = "res://Game/Maps/Base/Base.tscn" }
		get_node("/root/Game").goto_game_mode_scene(game_mode_node)
		game_mode_node.start()

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
				webrtc_reconnect_peer(match_peers[session_id])

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
