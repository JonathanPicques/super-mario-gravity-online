extends Control

onready var Game = get_node("/root/Game")

onready var KeyIconTexture = preload("res://Game/Menus/Textures/KeyIcon.png")
onready var LockIconTexture = preload("res://Game/Menus/Textures/LockIcon.png")
onready var UnlockIconTexture = preload("res://Game/Menus/Textures/UnlockIcon.png")

enum RoomState { none, join, public, private, offline }

var room_state = RoomState.none

func _ready():
	match Game.GameMultiplayer.is_matchmaking_available():
		true: set_room_state(RoomState.public)
		false: set_room_state(RoomState.offline)
	Game.GameMultiplayer.connect("matchmaking_online", self, "on_matchmaking_online")
	Game.GameMultiplayer.connect("matchmaking_offline", self, "on_matchmaking_offline")

func _process(delta: float):
	# toggle room status
	if room_state != RoomState.offline and Input.is_action_just_pressed("ui_toggle_room_status"):
		set_room_state(RoomState.public if room_state == RoomState.private else RoomState.private)
	# add a local player
	for input_device_id in range(0, 5):
		if Game.GameInput.is_device_action_just_pressed(input_device_id, "accept") and not Game.GameInput.is_device_used_by_player(input_device_id):
			print("ADD PLAYER with input ", input_device_id)
			Game.GameMultiplayer.add_player("", true, input_device_id)
	# remove a local player
	for player in Game.GameMultiplayer.players:
		if player.local and Game.GameInput.is_player_action_just_pressed(player.id, "cancel"):
			Game.GameMultiplayer.remove_player(player.id)

func set_room_state(new_room_state: int):
	room_state = new_room_state
	match room_state:
		RoomState.public:
			$RoomKey/Label.text = ""
			$RoomKey/TextureRect.texture = null
			$RoomStatus/Label.text = "Public"
			$RoomStatus/TextureRect.texture = UnlockIconTexture
		RoomState.private:
			$RoomKey/Label.text = "join_code"
			$RoomKey/TextureRect.texture = KeyIconTexture
			$RoomStatus/Label.text = "Private"
			$RoomStatus/TextureRect.texture = LockIconTexture
		RoomState.offline:
			$RoomKey/Label.text = ""
			$RoomKey/TextureRect.texture = null
			$RoomStatus/Label.text = "Offline"
			$RoomStatus/TextureRect.texture = null

func on_matchmaking_online():
	if room_state == RoomState.offline:
		set_room_state(RoomState.private)

func on_matchmaking_offline():
	set_room_state(RoomState.offline)
