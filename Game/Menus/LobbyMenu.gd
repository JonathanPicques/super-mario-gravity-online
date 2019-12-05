extends "res://Game/Maps/Map.gd"

enum State { none, join, public, private, offline }

var state = State.none

func _ready():
	# Set key icons
	$KeyCancel.visible = GameMultiplayer.get_lead_player().input_device_id == 0
	$KeyConfirm.visible = GameMultiplayer.get_lead_player().input_device_id == 0
	$KeyAlt1.visible = GameMultiplayer.get_lead_player().input_device_id == 0
	$KeyAlt2.visible = GameMultiplayer.get_lead_player().input_device_id == 0
	$KeyCtrlCancel.visible = GameMultiplayer.get_lead_player().input_device_id == 1
	$KeyCtrlConfirm.visible = GameMultiplayer.get_lead_player().input_device_id == 1
	$KeyCtrlAlt1.visible = GameMultiplayer.get_lead_player().input_device_id == 1
	$KeyCtrlAlt2.visible = GameMultiplayer.get_lead_player().input_device_id == 1
	
	# Re-add players in already added
	for player in GameMultiplayer.get_players():
		on_player_added(player)
		yield(get_tree(), "idle_frame")
		on_player_set_skin(player, player.skin_id)
		on_player_set_ready(player, player.ready)
	
	# Set initial status
	match GameMultiplayer.is_online():
		true: set_state(State.public)
		false: set_state(State.offline)
		
	# Listeners
	GameMultiplayer.connect("online", self, "on_online")
	GameMultiplayer.connect("offline", self, "on_offline")
	GameMultiplayer.connect("player_added", self, "on_player_added")
	GameMultiplayer.connect("player_removed", self, "on_player_removed")
	GameMultiplayer.connect("player_set_skin", self, "on_player_set_skin")
	GameMultiplayer.connect("player_set_ready", self, "on_player_set_ready")

func _process(delta: float):
	var lead_player = GameMultiplayer.get_lead_player()
	# back to home if cancel when not ready
	if Input.is_action_just_pressed("ui_cancel") and not GameMultiplayer.get_lead_player():
		Game.goto_home_menu_scene()
	# toggle room status
	if state != State.offline and Input.is_action_just_pressed("ui_toggle_room_status"):
		set_state(State.public if state == State.private else State.private)
	# start game if every player is ready
	if lead_player and GameInput.is_player_action_just_pressed(lead_player.id, "accept") and GameMultiplayer.is_every_player_ready():
		return Game.goto_maps_menu_scene()
	# add a local player
	for input_device_id in range(0, 5):
		if GameInput.is_device_action_just_pressed(input_device_id, "accept") and not GameInput.is_device_used_by_player(input_device_id):
			yield(get_tree(), "idle_frame")
			GameMultiplayer.add_player("Local player", true, input_device_id, GameMultiplayer.my_peer_id, GameMultiplayer.get_next_peer_player_id(GameMultiplayer.my_peer_id))
	# remove a player
	for player in GameMultiplayer.get_players():
		if player.local:
			if GameInput.is_player_action_just_pressed(player.id, "cancel"):
				GameMultiplayer.remove_player(player.id)
	# change skin or be ready
	for player in GameMultiplayer.get_players():
		if player.local:
			if GameInput.is_player_action_just_pressed(player.id, "use") and !player.ready:
				yield(get_tree(), "idle_frame")
				GameMultiplayer.player_set_skin(player.id, (player.skin_id + 1) % 4)
			if GameInput.is_player_action_just_pressed(player.id, "accept"):
				yield(get_tree(), "idle_frame")
				GameMultiplayer.player_set_ready(player.id, not player.ready)

func set_state(new_state: int):
	state = new_state
	match state:
		State.public:
			$CodeLabel.text = ""
			$StatusLabel.text = "Public"
			$Lock.visible = false
			$Key.visible = false
			$Unlock.visible = true
			$Offline.visible = false
			$WaitingPrivateLabel.visible = false
			$WaitingOfflineLabel.visible = false
			$WaitingPublicLabel.visible = true
			start_waiting()
		State.private:
			$CodeLabel.text = "join_code"
			$StatusLabel.text = "Private"
			$Lock.visible = true
			$Key.visible = true
			$Unlock.visible = false
			$Offline.visible = false
			$WaitingPrivateLabel.visible = true
			$WaitingOfflineLabel.visible = false
			$WaitingPublicLabel.visible = false
			cancel_waiting()
		State.offline:
			$CodeLabel.text = ""
			$StatusLabel.text = "Offline"
			$Lock.visible = false
			$Key.visible = false
			$Unlock.visible = false
			$Offline.visible = true
			$WaitingPrivateLabel.visible = false
			$WaitingOfflineLabel.visible = true
			$WaitingPublicLabel.visible = false
			cancel_waiting()

func start_waiting():
	if not GameMultiplayer.is_online():
		cancel_waiting()
	GameMultiplayer.start_matchmaking()

# @impure
func cancel_waiting():
	GameMultiplayer.finish_playing()

func on_online():
	if state == State.offline:
		set_state(State.private)

func on_offline():
	set_state(State.offline)

func on_player_added(player: Dictionary):
	var player_node := GameMultiplayer.spawn_player_node(player, PlayerSlot)
	# TODO: spawn GFX
	player_node.position = get_node("Player%dPosition" % (player.id + 1)).position
	player_node.set_dialog(0)

func on_player_removed(player: Dictionary):
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		# TODO: spawn GFX
		player_node.queue_free()

func on_player_set_skin(player: Dictionary, skin_id: int):
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		GameConst.replace_skin(player_node.PlayerSprite, skin_id) # todo move in player?

func on_player_set_ready(player: Dictionary, ready: bool):
	var player_node = GameMultiplayer.get_player_node(player.id)
	if player_node:
		player_node.set_dialog(player_node.DialogType.ready if ready else player_node.DialogType.none)