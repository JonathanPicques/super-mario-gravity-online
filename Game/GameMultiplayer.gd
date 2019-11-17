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
	input_device_id = -1
}

var webrtc_multiplayer: WebRTCMultiplayer

var nakama_next_peer_id := 1
var nakama_realtime_client = null

var my_peer_id = null
var my_session_id = null

var match_data = {}
var webrtc_peers = {}
var nakama_players = {}

# _ready connects to the nakama server and authenticates this devices.
# @driven(lifecycle)
# @impure
func _ready():
	create_webrtc_multiplayer()
	nakama_create_realtime_client()

# _process polls new events from nakama.
# @driven(lifecycle)
# @impure
func _process(delta: float) -> void:
	if nakama_realtime_client:
		nakama_realtime_client.poll()

##############
# Player API #
##############

# @impure
func add_player(name: String, local: bool, input_device_id: int = -1, peer_id: int = -1):
	# wait one frame to not invalidate player iterators
	yield(get_tree(), "idle_frame")
	# compute player id
	var id = get_next_player_id()
	# duplicate sample player info
	var player = sample_player.duplicate(true)
	# assign player info
	player.id = id
	player.name = name
	player.local = local
	player.peer_id = peer_id
	player.input_device_id = input_device_id
	# add player
	players.append(player)
	# emit signal to update lobby
	emit_signal("player_add", player)

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

##############
# Online API #
##############

func start_matchmaker():
	var promise = nakama_realtime_client.send({ matchmaker_add = {
		query = "*",
		min_count = 2,
		max_count = 4,
		string_properties = {
			players = JSON.print(players)
		}
	} })
	if promise.error == OK:
		promise.connect("completed", self, "on_nakama_realtime_client_matchmaker")
	print("nakama_create_realtime_client: matchmaking")

func create_webrtc_multiplayer():
	webrtc_multiplayer = WebRTCMultiplayer.new()
	webrtc_multiplayer.connect("peer_connected", self, "on_peer_connected")
	webrtc_multiplayer.connect("peer_disconnected", self, "on_peer_disconnected")

func on_peer_connected(peer_id: int):
	# run game
	for session_id in nakama_players:
		if nakama_players[session_id]['peer_id'] == peer_id:
			yield(add_player("Network Peer", false, -1, peer_id), "completed")
	# patch local player
	for player in players:
		if player.local:
			player.peer_id = my_peer_id
	# start game mode
	var game_mode_node = load("res://Game/Modes/Race/RaceGameMode.tscn").instance()
	game_mode_node.options = { map = "res://Game/Maps/Base/Base.tscn" }
	get_node("/root/Game").goto_game_mode_scene(game_mode_node)
	game_mode_node.start()

func on_peer_disconnected(peer_id: int):
	print("TODO: remove_player")

##############
# Nakama API #
##############

func is_matchmaking_available():
	return nakama_realtime_client != null

func nakama_create_realtime_client():
	var unique_id = String(OS.get_unix_time())
	# authenticate this device to the matchmaking server
	var promise = $NakamaRestClient.authenticate_device(unique_id, true)
	promise.error == OK and yield(promise, "completed")
	print("nakama_create_realtime_client: authenticate_device")
	# ensures the authentication was successfull and get our device account
	promise = $NakamaRestClient.get_account()
	promise.error == OK and yield(promise, "completed")
	print("nakama_create_realtime_client: get_account")
	# create the realtime matchmaking client
	nakama_realtime_client = $NakamaRestClient.create_realtime_client()
	if not nakama_realtime_client:
		print ("nakama_create_realtime_client: ko")
		return
	nakama_realtime_client.connect("error", self, "on_nakama_realtime_client_error")
	nakama_realtime_client.connect("disconnected", self, "on_nakama_realtime_client_disconnected")
	nakama_realtime_client.connect("match_data", self, "on_nakama_realtime_client_match_data")
	nakama_realtime_client.connect("match_presence", self, "on_nakama_realtime_client_match_presence")
	nakama_realtime_client.connect("matchmaker_matched", self, "on_nakama_realtime_client_matchmaker_matched")
	# all is good
	yield(nakama_realtime_client, "connected")
	print("nakama_create_realtime_client: create_realtime_client")
	emit_signal("matchmaking_online")

func on_nakama_realtime_client_error(error: Dictionary):
	pass

func on_nakama_realtime_client_disconnected(data: Dictionary):
	print("on_nakama_realtime_client_disconnected: ", data)
	nakama_realtime_client = null
	emit_signal("matchmaking_offline")

func on_nakama_realtime_client_matchmaker(data: Dictionary, request: Dictionary):
	pass

func on_nakama_realtime_client_match_data(data: Dictionary):
	var json = JSON.parse(data['data'])
	var content = json.result
	match data['op_code']:
		1:
			if content['target'] == my_session_id:
				var session_id = data['presence']['session_id']
				var webrtc_peer = webrtc_peers[session_id]
				match content['method']:
					'set_remote_description':
						webrtc_peer.set_remote_description(content['type'], content['sdp'])
					'add_ice_candidate':
						webrtc_peer.add_ice_candidate(content['media'], content['index'], content['name'])

func on_nakama_realtime_client_match_presence(data: Dictionary):
	if data.has('joins'):
		for u in data['joins']:
			if u['session_id'] == my_session_id:
					continue
			webrtc_connect_peer(nakama_players[u['session_id']])

func on_nakama_realtime_client_matchmaker_matched(data: Dictionary):
	if data.has('users') && data.has('token') && data.has('self'):
		# store our session_id
		my_session_id = data['self']['presence']['session_id']
		# store all matched sessions
		for u in data['users']:
			nakama_players[u['presence']['session_id']] = u['presence']
		# generate peer ids
		var session_ids = nakama_players.keys()
		session_ids.sort()
		for session_id in session_ids:
			nakama_players[session_id]['peer_id'] = nakama_next_peer_id
			if session_id == my_session_id:
				my_peer_id = nakama_next_peer_id
			nakama_next_peer_id += 1
		# create webrtc
		webrtc_multiplayer.initialize(nakama_players[my_session_id]['peer_id'])
		get_tree().set_network_peer(webrtc_multiplayer)
		# join game
		nakama_realtime_client.send({ match_join = {token = data['token']}}).connect("completed", self, "on_nakama_realtime_client_match_join")

func on_nakama_realtime_client_match_join(data: Dictionary, request: Dictionary):
	if data.has('match'):
		match_data = data['match']
		my_session_id = match_data['self']['session_id']
		for presence in match_data['presences']:
			if presence['session_id'] == my_session_id:
				continue
			webrtc_connect_peer(nakama_players[presence['session_id']])

func webrtc_connect_peer(nakama_player: Dictionary):
	if webrtc_peers.has(nakama_player['session_id']):
		return
	
	var webrtc_peer := WebRTCPeerConnection.new()
	webrtc_peer.initialize({
		"iceServers": [{ "urls": ["stun:stun.l.google.com:19302"] }]
	})
	webrtc_peer.connect("session_description_created", self, "_on_webrtc_peer_session_description_created", [nakama_player['session_id']])
	webrtc_peer.connect("ice_candidate_created", self, "_on_webrtc_peer_ice_candidate_created", [nakama_player['session_id']])

	webrtc_peers[nakama_player['session_id']] = webrtc_peer
	webrtc_multiplayer.add_peer(webrtc_peer, nakama_player['peer_id'])
	
	if my_session_id != nakama_player['session_id']:
		var result = webrtc_peer.create_offer()
		if result != OK:
			print("webrtc_connect_peer: Unable to create WebRTC offer")

func _on_webrtc_peer_session_description_created(type : String, sdp : String, session_id : String):
	var webrtc_peer = webrtc_peers[session_id]
	webrtc_peer.set_local_description(type, sdp)
	# Send this data to the peer so they can call call .set_remote_description().
	nakama_realtime_client.send({
		match_data_send = {
			op_code = 1,
			match_id = match_data['match_id'],
			data = JSON.print({
				method = "set_remote_description",
				target = session_id,
				type = type,
				sdp = sdp,
			}),
		},
	})

func _on_webrtc_peer_ice_candidate_created(media : String, index : int, name : String, session_id : String):
	nakama_realtime_client.send({
		match_data_send = {
			op_code = 1,
			match_id = match_data['match_id'],
			data = JSON.print({
				method = "add_ice_candidate",
				target = session_id,
				media = media,
				index = index,
				name = name,
			}),
		},
	})
