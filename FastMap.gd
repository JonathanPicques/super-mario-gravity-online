extends MapNode

func _ready():
	MultiplayerManager.add_player("Player 1", true, 0, 0, 0)
#	MultiplayerManager.add_player("Player 2", true, 1, 0, 1)
	Game.goto_game_mode_scene("res://Game/Modes/Race/RaceGameMode.tscn", { map = "res://Game/Maps/Debug.tscn" })
