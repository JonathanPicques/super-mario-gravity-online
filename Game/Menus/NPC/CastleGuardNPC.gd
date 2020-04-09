extends NPCNode

func on_talk():
	MapManager.current_map = {"name": "Random", "admin": true}
	Game.goto_lobby_menu_scene()
