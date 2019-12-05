extends Navigation2D

onready var MapSlot = $"."

# @impure
func _ready():
	# spawn player
	GameMultiplayer.spawn_player_nodes(MapSlot)
	var players := GameMultiplayer.get_players(GameMultiplayer.SortPlayerMethods.ranked)
	# map is not ready yet
	yield(get_tree(), "idle_frame")
	# put first player on top
	var first_player_node = GameMultiplayer.get_player_node(players[0].id)
	if first_player_node:
		first_player_node.position = $FlagStart.position
	# put other players on the bottom
	for player_id in range(1, players.size()):
		var player_node = GameMultiplayer.get_player_node(players[player_id].id)
		if player_node:
			player_node.position = get_node("Player%dPosition" % (player_id + 1)).position

func _process(delta: float):
	if GameInput.is_player_action_just_pressed(0, "cancel"):
		open_popup()

func open_popup():
	$Popup.visible = !$Popup.visible
	$Popup/RetryButton.grab_focus()

func _on_RetryButton_pressed():
	print("TODO: retry game")

func _on_LobbyButton_pressed():
	GameMultiplayer.finish_playing()
	Game.goto_lobby_menu_scene()

func _on_MapsButton_pressed():
	print("TODO: back to maps")

func _on_HomeButton_pressed():
	GameMultiplayer.finish_playing()
	Game.goto_home_menu_scene()
