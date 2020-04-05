extends NPCNode

func on_talk():
	MapManager.current_map = "Random"
	Game.goto_lobby_menu_scene()
