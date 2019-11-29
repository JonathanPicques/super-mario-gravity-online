extends Control

onready var Game = get_node("/root/Game")

# @impure
func _ready():
	if not Game.GameMultiplayer.is_online():
		cancel_waiting()
	Game.GameMultiplayer.connect("offline", self, "cancel_waiting")
	Game.GameMultiplayer.start_matchmaking()

# @impure
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		cancel_waiting()

# @impure
func cancel_waiting():
	Game.GameMultiplayer.finish_playing()
	Game.goto_lobby_menu_scene()
