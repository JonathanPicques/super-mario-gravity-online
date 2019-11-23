extends Control

onready var Game = get_node("/root/Game")

const KeyIconTexture := preload("res://Game/Menus/Textures/KeyIcon.png")
const LockIconTexture := preload("res://Game/Menus/Textures/LockIcon.png")
const UnlockIconTexture := preload("res://Game/Menus/Textures/UnlockIcon.png")

enum State { none, join, public, private, offline }

var state = State.none

func _ready():
	match Game.GameMultiplayer.is_matchmaking_available():
		true: set_state(State.public)
		false: set_state(State.offline)
	Game.GameMultiplayer.connect("matchmaking_online", self, "on_matchmaking_online")
	Game.GameMultiplayer.connect("matchmaking_offline", self, "on_matchmaking_offline")

func _process(delta: float):
	# back to home if cancel when not ready
	if Input.is_action_just_pressed("ui_cancel") and not Game.GameMultiplayer.get_lead_player():
		Game.goto_main_menu_scene()
	# toggle room status
	if state != State.offline and Input.is_action_just_pressed("ui_toggle_room_status"):
		set_state(State.public if state == State.private else State.private)
	# start game if every player is ready
	if Input.is_action_just_pressed("ui_accept") and Game.GameMultiplayer.is_every_player_ready():
		return start_game()
	# add a local player
	for input_device_id in range(0, 5):
		if Game.GameInput.is_device_action_just_pressed(input_device_id, "accept") and not Game.GameInput.is_device_used_by_player(input_device_id):
			yield(get_tree(), "idle_frame")
			Game.GameMultiplayer.add_player("Local player", true, input_device_id, Game.GameMultiplayer.my_peer_id, Game.GameMultiplayer.get_next_peer_player_id(Game.GameMultiplayer.my_peer_id))
	# remove a player
	for player in Game.GameMultiplayer.players:
		if player.local:
			if Game.GameInput.is_player_action_just_pressed(player.id, "cancel"):
				Game.GameMultiplayer.remove_player(player.id)
	# change skin or be ready
	for player in Game.GameMultiplayer.players:
		if player.local:
			if Game.GameInput.is_player_action_just_pressed(player.id, "left") and !player.ready:
				yield(get_tree(), "idle_frame")
				Game.GameMultiplayer.player_set_skin(player.id, (player.skin_id - 1) % len(Game.skins))
			if Game.GameInput.is_player_action_just_pressed(player.id, "right") and !player.ready:
				yield(get_tree(), "idle_frame")
				Game.GameMultiplayer.player_set_skin(player.id, (player.skin_id + 1) % len(Game.skins))
			if Game.GameInput.is_player_action_just_pressed(player.id, "accept"):
				yield(get_tree(), "idle_frame")
				Game.GameMultiplayer.player_set_ready(player.id, not player.ready)

func set_state(new_state: int):
	state = new_state
	match state:
		State.public:
			$RoomKey/Label.text = ""
			$RoomKey/TextureRect.texture = null
			$RoomStatus/Label.text = "Public"
			$RoomStatus/TextureRect.texture = UnlockIconTexture
		State.private:
			$RoomKey/Label.text = "join_code"
			$RoomKey/TextureRect.texture = KeyIconTexture
			$RoomStatus/Label.text = "Private"
			$RoomStatus/TextureRect.texture = LockIconTexture
		State.offline:
			$RoomKey/Label.text = ""
			$RoomKey/TextureRect.texture = null
			$RoomStatus/Label.text = "Offline"
			$RoomStatus/TextureRect.texture = null

func start_game():
	if state == State.public:
		Game.goto_waiting_room_menu_scene()
	else:
		var game_mode_node = load("res://Game/Modes/Race/RaceGameMode.tscn").instance()
		game_mode_node.options = { map = "res://Game/Maps/Base/Base.tscn" }
		Game.goto_game_mode_scene(game_mode_node)
		game_mode_node.start()

func on_matchmaking_online():
	if state == State.offline:
		set_state(State.private)

func on_matchmaking_offline():
	set_state(State.offline)
