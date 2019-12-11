extends "res://Game/Maps/Map.gd"

# @impure
func _ready():
	yield(get_tree(), "idle_frame")
	# music
	GameAudio.play_music("res://Game/Menus/Musics/Hand-in-Hand-in-Pixel-Land.ogg")
	# spawn player
	GameMultiplayer.spawn_player_nodes(PlayerSlot)
	var players := GameMultiplayer.get_players(GameMultiplayer.SortPlayerMethods.ranked)
	# put first player on top
	var first_player_node = GameMultiplayer.get_player_node(players[0].id)
	if first_player_node:
		first_player_node.position = $FlagStart.position
	# put other players on the bottom
	for player_id in range(1, players.size()):
		var player_node = GameMultiplayer.get_player_node(players[player_id].id)
		if player_node:
			player_node.position = get_node("Player%dPosition" % (player_id + 1)).position

# @impure
func _process(delta: float):
	if GameInput.is_player_action_just_pressed(0, "cancel"):
		open_popup()

# @impure
func open_popup():
	$GUI/Popup.visible = !$GUI/Popup.visible
	$GUI/Popup/RetryButton.grab_focus()

# block_input is used to avoid calling finish_playing multiple times.
var block_input := false

# @impure
# @signal
func _on_RetryButton_pressed():
	print("TODO: retry game")

# @impure
# @signal
func _on_LobbyButton_pressed():
	if not block_input:
		block_input = true
		GameMultiplayer.finish_playing()
		Game.goto_lobby_menu_scene()

# @impure
# @signal
func _on_MapsButton_pressed():
	print("TODO: back to maps")

# @impure
# @signal
func _on_HomeButton_pressed():
	if not block_input:
		block_input = true
		GameMultiplayer.finish_playing()
		Game.goto_home_menu_scene()
