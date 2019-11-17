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

# Nakama realtime matchmaking client
var nakama_realtime_client = null

# _ready connects to the nakama server and authenticates this devices.
# @driven(lifecycle)
# @impure
func _ready():
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
	} })
	if promise.error == OK:
		promise.connect("completed", self, "on_nakama_realtime_client_matchmaker")
	print("nakama_create_realtime_client: matchmaking")

##############
# Nakama API #
##############

func is_matchmaking_available():
	return nakama_realtime_client != null

func nakama_create_realtime_client():
	var promise
	# authenticate this device to the matchmaking server
	promise = $NakamaRestClient.authenticate_device(OS.get_unique_id(), true)
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
	nakama_realtime_client.connect("matchmaker_matched", self, "on_nakama_realtime_client_matchmaker_matched")
	# all is good
	yield(nakama_realtime_client, "connected")
	print("nakama_create_realtime_client: create_realtime_client")
	emit_signal("matchmaking_online")

func on_nakama_realtime_client_error(error: Dictionary):
	print("on_nakama_realtime_client_error: ", error)

func on_nakama_realtime_client_disconnected(data: Dictionary):
	print("on_nakama_realtime_client_disconnected: ", data)
	nakama_realtime_client = null
	emit_signal("matchmaking_offline")

func on_nakama_realtime_client_matchmaker(data: Dictionary, request: Dictionary):
	print(data, request)

func on_nakama_realtime_client_matchmaker_matched(data: Dictionary):
	print("Matched ", data)
