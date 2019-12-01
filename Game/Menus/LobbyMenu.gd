extends Navigation2D

onready var Game = get_node("/root/Game")
onready var MapSlot = $"."

enum State { none, join, public, private, offline }

var state = State.none

func _ready():
	for player in Game.GameMultiplayer.players:
		on_player_added(player)
		yield(get_tree(), "idle_frame")
		on_player_set_skin(player, player.skin_id)
		on_player_set_ready(player, player.ready)
	match Game.GameMultiplayer.is_online():
		true: set_state(State.public)
		false: set_state(State.offline)
	Game.GameMultiplayer.connect("online", self, "on_online")
	Game.GameMultiplayer.connect("offline", self, "on_offline")
	Game.GameMultiplayer.connect("player_added", self, "on_player_added")
	Game.GameMultiplayer.connect("player_removed", self, "on_player_removed")
	Game.GameMultiplayer.connect("player_set_skin", self, "on_player_set_skin")
	Game.GameMultiplayer.connect("player_set_ready", self, "on_player_set_ready")

func _process(delta: float):
	var lead_player = Game.GameMultiplayer.get_lead_player()
	# back to home if cancel when not ready
	if Input.is_action_just_pressed("ui_cancel") and not Game.GameMultiplayer.get_lead_player():
		Game.goto_home_menu_scene()
	# toggle room status
	if state != State.offline and Input.is_action_just_pressed("ui_toggle_room_status"):
		set_state(State.public if state == State.private else State.private)
	# start game if every player is ready
	if lead_player and Game.GameInput.is_player_action_just_pressed(lead_player.id, "accept") and Game.GameMultiplayer.is_every_player_ready():
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
			if Game.GameInput.is_player_action_just_pressed(player.id, "use") and !player.ready:
				yield(get_tree(), "idle_frame")
				Game.GameMultiplayer.player_set_skin(player.id, (player.skin_id + 1) % 4)
			if Game.GameInput.is_player_action_just_pressed(player.id, "accept"):
				yield(get_tree(), "idle_frame")
				Game.GameMultiplayer.player_set_ready(player.id, not player.ready)

func set_state(new_state: int):
	state = new_state
	match state:
		State.public:
			$CodeLabel.text = ""
			$StatusLabel.text = "Public"
		State.private:
			$CodeLabel.text = "join_code"
			$StatusLabel.text = "Private"
		State.offline:
			$CodeLabel.text = ""
			$StatusLabel.text = "Offline"

func start_game():
	if state == State.public:
		Game.goto_waiting_menu_scene()
	else:
		Game.goto_maps_menu_scene()
#		var game_mode_node = load("res://Game/Modes/Race/RaceGameMode.tscn").instance()
#		game_mode_node.options = { map = "res://Game/Maps/Base/Base.tscn" }
#		Game.goto_game_mode_scene(game_mode_node)
#		game_mode_node.start()

func on_online():
	if state == State.offline:
		set_state(State.private)

func on_offline():
	set_state(State.offline)

func on_player_added(player: Dictionary):
	var player_node = Game.GameMultiplayer.spawn_player_node(player, MapSlot)
	# TODO: spawn GFX
	player_node.position = get_node("Player%dPosition" % (player.id + 1)).position
	player_node.set_dialog(0)

func on_player_removed(player: Dictionary):
	var player_node = Game.GameMultiplayer.get_player_node(player.id)
	if player_node:
		# TODO: spawn GFX
		player_node.queue_free()

func on_player_set_skin(player: Dictionary, skin_id: int):
	var player_node = Game.GameMultiplayer.get_player_node(player.id)
	Game.GameConst.replace_skin(player_node.PlayerSprite, skin_id) # todo move in player?

func on_player_set_ready(player: Dictionary, ready: bool):
	var player_node = Game.GameMultiplayer.get_player_node(player.id)
	player_node.set_dialog(player_node.DialogType.ready if ready else player_node.DialogType.none)
