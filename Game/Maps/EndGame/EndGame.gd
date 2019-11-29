extends Navigation2D

onready var Game = get_node("/root/Game")
onready var MapSlot = $"."

# @impure
func _ready():
	# spawn player
	Game.GameMultiplayer.spawn_player_nodes(MapSlot)
	var players = Game.GameMultiplayer.get_players(Game.GameMultiplayer.SortPlayerMethods.ranked)
	# map is not ready yet
	yield(get_tree(), "idle_frame")
	# put first player on top
	var first_player_node = Game.GameMultiplayer.get_player_node(players[0].id)
	first_player_node.position = $FlagStart.position
	# put other players on the bottom
	for player_id in range(1, players.size()):
		var player_node = Game.GameMultiplayer.get_player_node(players[player_id].id)
		player_node.position = get_node("Player%dPosition" % (player_id + 1)).position

func _process(delta: float):
	if Game.GameInput.is_player_action_just_pressed(0, "cancel"):
		Game.GameMultiplayer.finish_playing()
		Game.goto_lobby_menu_scene()
