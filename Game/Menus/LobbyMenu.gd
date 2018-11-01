extends Control

onready var LobbyPlayers = [
	$LobbyPlayerMenu1,
	$LobbyPlayerMenu2,
	$LobbyPlayerMenu3,
	$LobbyPlayerMenu4,
	$LobbyPlayerMenu5,
	$LobbyPlayerMenu6,
]

# set_players set the players in the lobby players boxes.
# @impure
func set_players(players: Dictionary):
	for lobby_player in LobbyPlayers:
		lobby_player.joined = false
	for player_id in players:
		var player = players[player_id]
		var lobby_player = LobbyPlayers[player.index]
		lobby_player.host = player.id == 1
		lobby_player.joined = true
		lobby_player.self_player = false
		lobby_player.find_node("PlayerName").text = player.name