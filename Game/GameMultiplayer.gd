extends Node

signal player_add
signal player_remove
signal player_set_skin
signal player_set_ready

signal matchmaking_online
signal matchmaking_offline

const MAX_PLAYERS = 4

# players
var players = []

# required properties for a player to be valid
var sample_player = {
	id = -1,
	name = "",
	local = true,
	ready = false,
	skin_id = 0,
	peer_id = -1,
	peer_player_id = -1,
	input_device_id = -1
}

var my_peer_id = null
var my_session_id = null
var next_available_peer_id := 1

var matchmaker = null
var match_data = {}
var match_peers = {}
var webrtc_peers = {}
var matchmaker_ticket = null
var webrtc_multiplayer: WebRTCMultiplayer

# _ready connects to the matchmaking server and authenticates this device.
# @driven(lifecycle)
# @impure
func _ready():
	init_matchmaker()
	init_webrtc_multiplayer()

# _process polls new events from matchmaking.
# @driven(lifecycle)
# @impure
func _process(delta: float) -> void:
	if matchmaker:
		matchmaker.poll()

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
func remove_player(player_id: int):
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
		print("warning: remove_player player not found")

# @impure
func player_set_skin(player_id: int, skin_id: int):
	get_player(player_id).skin_id = skin_id
	emit_signal("player_set_skin", player_id, skin_id)

# @impure
func player_set_ready(player_id: int, ready: bool):
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
	
# get_closest_player returns the closest player in front of you
func get_closest_player(player_id: int): # FIXME: shouldn't pass the ID 
	for player in players:
		if player.id != player_id:
			return player
	return null

# is_local_player returns true if the given player_id is locally handled.
# @pure
func is_local_player(player_id: int):
	return players[player_id].local

# get_next_player_id returns the next player id available.
# @pure
func get_next_player_id() -> int:
	var id := 0
	var restart := true
	while restart:
		restart = false
		for player in players:
			var player_id = player.id
			if id == player_id:
				id += 1
				restart = true
	return id

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
func has_room_for_new_player():
	return players.size() < MAX_PLAYERS

###############
# Matchmaking #
###############

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

func start_matchmaking():
	var player_count = players.size()
	for i in range(MAX_PLAYERS, player_count - 1, -1):
		print("start_matchmaking: query(", "+properties.player_count:>=%d" % i, ")")
		var promise = matchmaker.send({ matchmaker_add = {
			query = "+properties.player_count:>=%d" % i,
			min_count = 2,
			max_count = 4,
			string_properties = {
				players = JSON.print(players),
			},
			numeric_properties = {
				player_count = player_count
			}
		} })
		if promise.error == OK:
			print("start_matchmaking: ok")
		promise.connect("completed", self, "on_matchmaker_add")
		yield(get_tree().create_timer(4), "timeout")
		if matchmaker_ticket == null:
			return
		yield(finish_matchmaking(), "completed")

func finish_matchmaking():
	if matchmaker_ticket == null:
		print("finish_matchmaking: warning no matchmaking in progress")
		return
	var promise = matchmaker.send({ matchmaker_remove = { ticket = matchmaker_ticket } })
	promise.error == OK and yield(promise, "completed")
	print("finish_matchmaking: ok")

func is_matchmaking_available():
	return matchmaker != null

func on_matchmaker_add(data: Dictionary, request: Dictionary):
	if data.has('matchmaker_ticket'):
		matchmaker_ticket = data['matchmaker_ticket']['ticket']

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

func on_matchmaker_match_join(data: Dictionary, request: Dictionary):
	if data.has('match'):
		match_data = data['match']
		my_session_id = match_data['self']['session_id']
		for match_peer in match_data['presences']:
			if match_peer['session_id'] == my_session_id:
				continue
			webrtc_connect_peer(match_peers[match_peer['session_id']])

func on_matchmaker_match_data(data: Dictionary):
	var json = JSON.parse(data['data'])
	var content = json.result
	match data['op_code']:
		1:
			if content['target'] == my_session_id:
				var session_id = data['presence']['session_id']
				var webrtc_peer = webrtc_peers[session_id]
				match content['method']:
					'add_ice_candidate':
						webrtc_peer.add_ice_candidate(content['media'], content['index'], content['name'])
					'set_remote_description':
						webrtc_peer.set_remote_description(content['type'], content['sdp'])

func on_matchmaker_match_presence(data: Dictionary):
	if data.has('joins'):
		for match_peer in data['joins']:
			if match_peer['session_id'] == my_session_id:
					continue
			webrtc_connect_peer(match_peers[match_peer['session_id']])

func on_matchmaker_error(error: Dictionary):
	print("on_matchmaker_error: ", error)
	matchmaker = null
	emit_signal("matchmaking_offline")

func on_matchmaker_disconnected(data: Dictionary):
	print("on_matchmaker_disconnected: ", data)
	matchmaker = null
	emit_signal("matchmaking_offline")

######################
# Multiplayer WebRTC #
######################

func init_webrtc_multiplayer():
	webrtc_multiplayer = WebRTCMultiplayer.new()
	webrtc_multiplayer.connect("peer_connected", self, "on_webrtc_peer_connected")
	webrtc_multiplayer.connect("peer_disconnected", self, "on_webrtc_peer_disconnected")

func webrtc_connect_peer(match_peer: Dictionary):
	if webrtc_peers.has(match_peer['session_id']):
		return
	
	var webrtc_peer := WebRTCPeerConnection.new()
	webrtc_peer.initialize({
		"iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }]
	})
	webrtc_peer.connect("ice_candidate_created", self, "on_webrtc_peer_ice_candidate_created", [match_peer['session_id']])
	webrtc_peer.connect("session_description_created", self, "on_webrtc_peer_session_description_created", [match_peer['session_id']])

	webrtc_peers[match_peer['session_id']] = webrtc_peer
	webrtc_multiplayer.add_peer(webrtc_peer, match_peer['peer_id'])
	
	if my_session_id.casecmp_to(match_peer['session_id']) < 0:
		var result = webrtc_peer.create_offer()
		if result != OK:
			print("webrtc_connect_peer: unable to create webrtc offer")

func on_webrtc_peer_connected(peer_id: int):
	print(peer_id, " connected ", match_peers.size(), "/", 3)
	# create player from peer
	for session_id in match_peers:
		var match_peer = match_peers[session_id]
		if match_peer['peer_id'] == peer_id:
			var peer_player_id := 0
			for match_peer_player in match_peer['players']:
				var player := add_player("Network Peer", false, -1, peer_id, peer_player_id)
				player_set_skin(player.id, match_peer_player.skin_id)
				player_set_ready(player.id, match_peer_player.ready)
				peer_player_id += 1
	# start game if there are enough players
	if players.size() >= 1:
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

func on_webrtc_peer_disconnected(peer_id: int):
	print("TODO: remove_player")

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
