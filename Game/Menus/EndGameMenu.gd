extends "res://Game/Maps/Map.gd"

# @impure
func _ready():
	yield(get_tree(), "idle_frame")
	# music
	AudioManager.play_music("res://Game/Menus/Musics/Hand-in-Hand-in-Pixel-Land.ogg")
	# spawn player
	MultiplayerManager.spawn_player_nodes(PlayerSlot)
	var players := MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)
	# put first player on top
	var first_player_node = MultiplayerManager.get_player_node(players[0].id)
	if first_player_node:
		first_player_node.position = $FlagStart.position
	# put other players on the bottom
	for player_id in range(1, players.size()):
		var player_node = MultiplayerManager.get_player_node(players[player_id].id)
		if player_node:
			player_node.position = get_node("Player%dPosition" % (player_id + 1)).position

# @impure
func _process(delta: float):
	if InputManager.is_player_action_just_pressed(0, "cancel"):
		toggle_popup(!$GUI/Popup.visible)

# @impure
func toggle_popup(is_open):
	$GUI/Popup.visible = is_open
	$GUI/Popup/ReplayButton.grab_focus()

# block_input is used to avoid calling finish_playing multiple times.
var block_input := false

func _on_ReplayButton_pressed():
	if not block_input:
		block_input = true
		MultiplayerManager.finish_playing()
		Game.goto_lobby_menu_scene()


func _on_HomeButton_pressed():
	if not block_input:
		block_input = true
		MultiplayerManager.finish_playing()
		Game.goto_home_menu_scene()
