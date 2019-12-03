extends Navigation2D

# @impure
func _ready():
	if not GameMultiplayer.is_online():
		cancel_waiting()
	GameMultiplayer.connect("offline", self, "cancel_waiting")
	GameMultiplayer.start_matchmaking()

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_waiting()

# @impure
func cancel_waiting():
	GameMultiplayer.finish_playing()
	Game.goto_lobby_menu_scene()
