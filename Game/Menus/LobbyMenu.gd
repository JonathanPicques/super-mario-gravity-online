extends "res://Game/Maps/Map.gd"

enum State { none, join, public, private, offline }

var state = State.none

var time_before_start = 120 # TODO: do this server side!

# @impure
func _ready():
	# Music
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	# Set icons
	var lead_player = MultiplayerManager.get_lead_player()
	if lead_player:
		$Icons/KeyGamepadAlt1.visible = lead_player.input_device_id == 1
		$Icons/KeyGamepadAlt2.visible = lead_player.input_device_id == 1
		$Icons/KeyGamepadCancel.visible = lead_player.input_device_id == 1
		$Icons/KeyGamepadConfirm.visible = lead_player.input_device_id == 1
		$Icons/KeyKeyboardAlt1.visible = lead_player.input_device_id == 0
		$Icons/KeyKeyboardAlt2.visible = lead_player.input_device_id == 0
		$Icons/KeyKeyboardCancel.visible = lead_player.input_device_id == 0
		$Icons/KeyKeyboardConfirm.visible = lead_player.input_device_id == 0
	# Map
	if MapManager.current_map["name"] == "Random":
		$GUI/MapButton/Label.text = "Random"
		$GUI/MapButton.apply_random(true)
	elif MapManager.current_map["name"] == "YourRandom":
		$GUI/MapButton/Label.text = "Random"
		$GUI/MapButton.apply_random(false)
	else:
		var map_info = MapManager.load_map_json(MapManager.current_map)
		$GUI/MapButton/Label.text = map_info["name"]
		$GUI/MapButton/Preview.texture = load("res://Maps/" + MapManager.current_map["name"].get_basename() + ".png")
	# Set initial status
	match MultiplayerManager.is_online():
		true: set_state(State.public)
		false: set_state(State.offline)
	# Connect matchmaking listeners
	MultiplayerManager.connect("online", self, "on_online")
	MultiplayerManager.connect("offline", self, "on_offline")

# @impure
func _process(delta: float):
	var lead_player = MultiplayerManager.get_lead_player()
	# back to home if cancel when not ready
	if Input.is_action_just_pressed("ui_cancel") and not MultiplayerManager.get_lead_player():
		set_process(false) # disable process to avoid calling goto_home_menu_scene multiple times.
		return Game.goto_home_menu_scene()
	# toggle room status
	if state != State.offline and Input.is_action_just_pressed("ui_toggle_room_status"):
		set_state(State.public if state == State.private else State.private)
	# start game if every player is ready
	if lead_player and InputManager.is_player_action_just_pressed(lead_player.id, "accept") and MultiplayerManager.is_every_player_ready():
		return start_game()
	# add a local player
	for input_device_id in range(0, 5):
		if InputManager.is_device_action_just_pressed(input_device_id, "accept") and not InputManager.is_device_used_by_player(input_device_id):
			yield(get_tree(), "idle_frame")
			MultiplayerManager.add_player("Local player", true, input_device_id, MultiplayerManager.my_peer_id, MultiplayerManager.get_next_player_local_id(MultiplayerManager.my_peer_id))
	# remove a player
	for player in MultiplayerManager.get_players():
		if player.local:
			if InputManager.is_player_action_just_pressed(player.id, "cancel"):
				MultiplayerManager.remove_player(player.id)
	# change skin or be ready
	for player in MultiplayerManager.get_players():
		if player.local:
			if InputManager.is_player_action_just_pressed(player.id, "use") and !player.ready:
				yield(get_tree(), "idle_frame")
				MultiplayerManager.player_set_skin(player.id, (player.skin_id + 1) % 6)
			if InputManager.is_player_action_just_pressed(player.id, "accept"):
				yield(get_tree(), "idle_frame")
				MultiplayerManager.player_set_ready(player.id, not player.ready)

# @impure
func set_state(new_state: int):
	state = new_state
	match state:
		State.public:
			$GUI/CodeLabel.text = ""
			$GUI/StatusLabel.text = "Public"
#			$GUI/WaitingPublicLabel.visible = true
#			$GUI/WaitingPrivateLabel.visible = false
#			$GUI/WaitingOfflineLabel.visible = false
			$Icons/Key.visible = false
			$Icons/Lock.visible = false
			$Icons/Unlock.visible = true
			$Icons/Offline.visible = false
			start_waiting()
		State.private:
			$GUI/CodeLabel.text = "join_code"
			$GUI/StatusLabel.text = "Private"
#			$GUI/WaitingPublicLabel.visible = false
#			$GUI/WaitingPrivateLabel.visible = true
#			$GUI/WaitingOfflineLabel.visible = false
			$Icons/Key.visible = true
			$Icons/Lock.visible = true
			$Icons/Unlock.visible = false
			$Icons/Offline.visible = false
			cancel_waiting()
		State.offline:
			$GUI/CodeLabel.text = ""
			$GUI/StatusLabel.text = "Offline"
#			$GUI/WaitingPublicLabel.visible = false
#			$GUI/WaitingPrivateLabel.visible = false
#			$GUI/WaitingOfflineLabel.visible = true
			$Icons/Key.visible = false
			$Icons/Lock.visible = false
			$Icons/Unlock.visible = false
			$Icons/Offline.visible = true
			cancel_waiting()

# start_waiting is called to start matchmaking.
# @impure
func start_waiting():
	MultiplayerManager.start_matchmaking()

# cancel_waiting is called to stop matchmaking.
# @impure
func cancel_waiting():
	MultiplayerManager.finish_playing()

func start_game():
		# disable process to avoid calling goto_game_mode_scene multiple times.
	set_process(false)
	# stop matchmaking
	MultiplayerManager.finish_matchmaking()
	return Game.goto_game_mode_scene("res://Game/Modes/Race/RaceGameMode.tscn", {})

# on_online is called when the connection to the matchmaking is recovered.
# @signal
# @impure
func on_online():
	if state == State.offline:
		set_state(State.private)

# on_offline is called when the connection to the matchmaking is lost.
# @signal
# @impure
func on_offline():
	set_state(State.offline)


func _on_MapButton_pressed():
	Game.goto_select_map_scene()


func pretty_time(value: int) -> String:
	var minutes = value / 60
	var seconds = value % 60
	return "0" + String(minutes) + ":" + ("0" if seconds < 10 else "") + String(seconds)

func _on_Timer_timeout():
	time_before_start -= 1
	$GUI/InfoLabel.text = "The game starts in " + pretty_time(time_before_start) + " or when everyone is ready"
	if time_before_start == 0:
		start_game()
