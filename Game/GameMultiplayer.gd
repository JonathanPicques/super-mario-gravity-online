extends Node
class_name GameMultiplayerNode

signal player_add
signal player_remove
signal player_set_skin
signal player_set_ready

signal matchmaking_online
signal matchmaking_offline

const MAX_PLAYERS := 4

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
	rank_distance = 0,
}

var my_peer_id := -1
var my_session_id = null
var next_available_peer_id := 1

var matchmaker = null
var matchmaker_ticket = null

var match_data := {}
var match_peers := {}

var webrtc_peers := {}
var webrtc_peers_ok := {}
var webrtc_multiplayer: WebRTCMultiplayer

# _ready connects to the matchmaking server and authenticates this device.
# @driven(lifecycle)
# @impure
func _ready():
	init_matchmaker()
	init_webrtc()

# _process polls new events from matchmaking.
# @driven(lifecycle)
# @impure
func _process(delta: float) -> void:
	if matchmaker:
		matchmaker.poll()
	if Input.is_action_just_pressed("ui_cancel"):
		print("disconnect")
		webrtc_multiplayer.remove_peer(2)

# _notification is called to check if the application is quitting to dispose of network resources.
# @driven(lifecycle)
# @impure
func _notification(event):
	if event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		finish_matchmaking()
		finish_webrtc()

##############
# Player API #
##############

# @impure
func add_player(name: String, local: bool, input_device_id: int = -1, peer_id: int = -1, peer_player_id: int = -1) -> Dictionary:
	# compute player id
	var id = get_next_player_id()
	# duplicate sample player info
	var player = sample_player.duplicate(true)
	# assign player info
	player.id = id
	player.name = name
	player.local = local
	player.peer_id = peer_id
	player.peer_player_id = peer_player_id
	player.input_device_id = input_device_id
	# add player
	players.append(player)
	# emit signal to update lobby
	emit_signal("player_add", player)
	# return new player
	return player

# @impure
func remove_player(player_id: int) -> void:
	# wait one frame to not invalidate player iterators
	yield(get_tree(), "idle_frame")
	# find if player exists
	var player = get_player(player_id)
	if player:
		# actually remove the player
		players.erase(player)
		# emit signal to update lobby
		emit_signal("player_remove", player)
	else:
		print("remove_player: warning player not found")

# @impure
func player_set_skin(player_id: int, skin_id: int) -> void:
	get_player(player_id).skin_id = skin_id
	emit_signal("player_set_skin", player_id, skin_id)

# @impure
func player_set_ready(player_id: int, ready: bool) -> void:
	get_player(player_id).ready = ready
	emit_signal("player_set_ready", player_id, ready)

# get_player return the player by the given id.
# @pure
func get_player(player_id: int):
	for player in players:
		if player.id == player_id:
			return player
	return null

# get_lead_player returns the local lead player or null.
# @pure
func get_lead_player():
	return players[0] if players.size() > 0 else null
	
# get_closest_player returns the closest player in front of you.
# @pure
func get_closest_player(player_id: int): # FIXME: shouldn't pass the ID 
	for player in players:
		if player.id != player_id:
			return player
	return null

# is_local_player returns true if the given player_id is locally handled.
# @pure
func is_local_player(player_id: int) -> bool:
	return players[player_id].local

# get_local_player_count returns the number of local players.
# @pure
func get_local_player_count() -> int:
	var count := 0
	for player in players:
		if player.local:
			count += 1
	return count

# get_next_player_id returns the next player id available.
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

# get_next_peer_player_id returns the next peer player id available.
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

# has_server_authority returns true if we have the authority (local player only or network server).
# @pure
func has_server_authority() -> bool:
	return get_local_player_count() == players.size() or get_tree().is_network_server()

# is_every_player_ready returns true if every player is ready.
# @pure
func is_every_player_ready() -> bool:
	if players.empty():
		return false
	for player in players:
		if not player.ready:
			return false
	return true

# has_room_for_new_player return true if there is room for another player.
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

###############
# Matchmaking #
###############

# @pure
func is_matchmaking_available():
	return matchmaker != null

# @impure
func init_matchmaker():
	var unique_id := String(OS.get_unix_time())
	# authenticate this device to the matchmaking server
	var promise = $NakamaRestClient.authenticate_device(unique_id, true)
	promise.error == OK and yield(promise, "completed")
	print("init_matchmaker: authenticate_device")
	# ensures the authentication was successfull and get our device account
	promise = $NakamaRestClient.get_account()
	promise.error == OK and yield(promise, "completed")
	print("init_matchmaker: get_account")
	# create the realtime matchmaking client
	matchmaker = $NakamaRestClient.create_realtime_client()
	if not matchmaker:
		print ("init_matchmaker: ko")
		return
	matchmaker.connect("error", self, "on_matchmaker_error")
	matchmaker.connect("disconnected", self, "on_matchmaker_disconnected")
	matchmaker.connect("match_data", self, "on_matchmaker_match_data")
	matchmaker.connect("match_presence", self, "on_matchmaker_match_presence")
	matchmaker.connect("matchmaker_matched", self, "on_matchmaker_matched")
	# all is good
	yield(matchmaker, "connected")
	print("init_matchmaker: ok")
	emit_signal("matchmaking_online")

# @impure
func start_matchmaking():
	var player_count := players.size()
	for player_preferred_count in range(MAX_PLAYERS - player_count, 0, -1):
		# try to query the preferred player count
		var query := "+properties.player_count:%d" % player_preferred_count
		# send a request to the matchmaker
		var promise = matchmaker.send({ matchmaker_add = {
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
		# read response from matchmaker
		if promise.error == OK:
			print("start_matchmaking: %s" % query)
			promise.connect("completed", self, "on_matchmaker_add")
		else:
			finish_matchmaking()
		# if there is no match found after a while, retry with lower expectations
		if player_preferred_count > 1:
			# wait a bit before restarting matchmaking
			yield(get_tree().create_timer(4), "timeout")
			# if the matchmaker ticket is consumed, we successfully found a match
			if matchmaker_ticket == null:
				return
			# otherwise restart matchmaking with lower expectations
			yield(finish_matchmaking(), "completed")

# @impure
func finish_matchmaking():
	if matchmaker_ticket == null:
		print("finish_matchmaking: warning no matchmaking in progress")
		return
	var promise = matchmaker.send({ matchmaker_remove = { ticket = matchmaker_ticket } })
	promise.error == OK and yield(promise, "completed")
	print("finish_matchmaking: ok")

# @impure
func on_matchmaker_add(data: Dictionary, request: Dictionary):
	if data.has('matchmaker_ticket'):
		matchmaker_ticket = data['matchmaker_ticket']['ticket']

# @impure
func on_matchmaker_matched(data: Dictionary):
	if data.has('self') && data.has('token') && data.has('users'):
		# store our session_id
		my_session_id = data['self']['presence']['session_id']
		# store all matched sessions
		for match_peer in data['users']:
			match_peers[match_peer['presence']['session_id']] = match_peer['presence']
			match_peers[match_peer['presence']['session_id']]['players'] = JSON.parse(match_peer['string_properties']['players']).result
		# generate peer ids
		var session_ids = match_peers.keys()
		session_ids.sort()
		for session_id in session_ids:
			match_peers[session_id]['peer_id'] = next_available_peer_id
			if session_id == my_session_id:
				my_peer_id = match_peers[session_id]['peer_id']
			print("session_id(", session_id ,") is peer_id(", match_peers[session_id]['peer_id'], ")")
			next_available_peer_id += 1
		# create webrtc
		webrtc_multiplayer.initialize(match_peers[my_session_id]['peer_id'])
		get_tree().set_network_peer(webrtc_multiplayer)
		# join game
		matchmaker.send({ match_join = {token = data['token']}}).connect("completed", self, "on_matchmaker_match_join")
		# remove matchmaking ticket
		matchmaker_ticket = null

# @impure
func on_matchmaker_match_join(data: Dictionary, request: Dictionary):
	if data.has('match'):
		match_data = data['match']
		my_session_id = match_data['self']['session_id']
		for match_peer in match_data['presences']:
			if match_peer['session_id'] == my_session_id:
				continue
			webrtc_connect_peer(match_peers[match_peer['session_id']])

# @impure
func on_matchmaker_match_data(data: Dictionary):
	var json = JSON.parse(data['data'])
	var content = json.result
	match data['op_code']:
		1:
			if content['target'] == my_session_id:
				var session_id = data['presence']['session_id']
				var webrtc_peer = webrtc_peers[session_id]
				match content['method']:
					'reconnect':
						# a peer lost his connection to us, try to reconnect with him
						webrtc_multiplayer.remove_peer(match_peers[session_id]['peer_id'])
						webrtc_reconnect_peer(match_peers[session_id])
					'add_ice_candidate':
						webrtc_peer.add_ice_candidate(content['media'], content['index'], content['name'])
					'set_remote_description':
						webrtc_peer.set_remote_description(content['type'], content['sdp'])

# @impure
func on_matchmaker_match_presence(data: Dictionary):
	if data.has('joins'):
		for join_match_peer in data['joins']:
			if join_match_peer['session_id'] != my_session_id:
				webrtc_connect_peer(match_peers[join_match_peer['session_id']])
	if data.has('leaves'):
		for leave_match_peer in data['leaves']:
			if leave_match_peer['session_id'] != my_session_id:
				webrtc_disconnect_peer(match_peers[leave_match_peer['session_id']])

# @impure
func on_matchmaker_error(error: Dictionary):
	print("on_matchmaker_error: ", error)
	matchmaker = null
	emit_signal("matchmaking_offline")

# @impure
func on_matchmaker_disconnected(data: Dictionary):
	print("on_matchmaker_disconnected: ", data)
	matchmaker = null
	emit_signal("matchmaking_offline")

######################
# Multiplayer WebRTC #
######################

# @impure
func init_webrtc():
	webrtc_multiplayer = WebRTCMultiplayer.new()
	webrtc_multiplayer.connect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.connect("peer_disconnected", self, "on_webrtc_peer_disconnected")

# @impure
func finish_webrtc():
	webrtc_multiplayer.close()
	webrtc_multiplayer.disconnect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.disconnect("peer_disconnected", self, "on_webrtc_peer_disconnected")
	webrtc_multiplayer = null
	get_tree().set_network_peer(null)

# @impure
func webrtc_connect_peer(match_peer: Dictionary):
	if webrtc_peers.has(match_peer['session_id']):
		return
	# create webrtc peer
	var webrtc_peer := WebRTCPeerConnection.new()
	webrtc_peer.initialize({
		"iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }]
	})
	webrtc_peer.connect("ice_candidate_created", self, "on_webrtc_peer_ice_candidate_created", [match_peer['session_id']])
	webrtc_peer.connect("session_description_created", self, "on_webrtc_peer_session_description_created", [match_peer['session_id']])
	# link matchmaking peer and webrtc peer
	webrtc_peers[match_peer['session_id']] = webrtc_peer
	webrtc_multiplayer.add_peer(webrtc_peer, match_peer['peer_id'])
	# create offer on one side
	if my_session_id.casecmp_to(match_peer['session_id']) < 0:
		var result = webrtc_peer.create_offer()
		if result != OK:
			print("webrtc_connect_peer: unable to create webrtc offer")

# @impure
func webrtc_reconnect_peer(match_peer: Dictionary):
	var webrtc_peer = webrtc_peers[match_peer['session_id']]
	# destroy the peer...
	webrtc_peer.close()
	webrtc_peers.erase(match_peer['session_id'])
	webrtc_peers_ok.erase(match_peer['session_id'])
	# ... and try to (re)connect the peer
	webrtc_connect_peer(match_peer)

# @impure
func webrtc_disconnect_peer(match_peer: Dictionary):
	var webrtc_peer = webrtc_peers[match_peer['session_id']]
	# destroy the peer...
	webrtc_peer.close()
	webrtc_peers.erase(match_peer['session_id'])
	webrtc_peers_ok.erase(match_peer['session_id'])

# @impure
func on_webrtc_peer_connected(peer_id: int):
	print("on_webrtc_peer_connected: ", peer_id)
	# start game if all webrtc peers are ok
	if true: # webrtc_peers_ok.size() == players.size() - 1:
		# create player from webrtc peers
		for session_id in match_peers:
			var match_peer = match_peers[session_id]
			if match_peer['peer_id'] == peer_id:
				webrtc_peers_ok[session_id] = true
				var peer_player_id := 0
				for match_peer_player in match_peer['players']:
					# create a player for each local player in this peer.
					var player := add_player("Network Peer", false, -1, peer_id, peer_player_id)
					player_set_skin(player.id, match_peer_player.skin_id)
					player_set_ready(player.id, match_peer_player.ready)
					peer_player_id += 1
		# patch local player
		for player in players:
			if player.local:
				player.peer_id = my_peer_id
				player.peer_player_id = player.id
		# start game mode
		var game_mode_node = load("res://Game/Modes/Race/RaceGameMode.tscn").instance()
		game_mode_node.options = { map = "res://Game/Maps/Base/Base.tscn" }
		get_node("/root/Game").goto_game_mode_scene(game_mode_node)
		game_mode_node.start()

# @impure
func on_webrtc_peer_disconnected(peer_id: int):
	print("on_webrtc_peer_disconnected: ", peer_id)
	# we lost the webrtc connection to this peer...
	for session_id in match_peers:
		if match_peers[session_id]['peer_id'] == peer_id:
			# ... offer the peer to reconnect via the matchmaking channel ...
			if my_session_id.casecmp_to(session_id) < 0:
				matchmaker.send({
					match_data_send = {
						op_code = 1,
						match_id = match_data['match_id'],
						data = JSON.print({
							method = "reconnect",
							target = session_id,
						}),
					},
				})
				# ... and try to reconnect the peer on our end, he will do the same when receiving our offer
				webrtc_reconnect_peer(match_peers[session_id])

# @impure
func on_webrtc_peer_ice_candidate_created(media: String, index: int, name: String, session_id: String):
	matchmaker.send({
		match_data_send = {
			op_code = 1,
			match_id = match_data['match_id'],
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
	matchmaker.send({
		match_data_send = {
			op_code = 1,
			match_id = match_data['match_id'],
			data = JSON.print({
				sdp = sdp,
				type = type,
				target = session_id,
				method = "set_remote_description",
			}),
		},
	})
