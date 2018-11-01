extends Control

# host_game is emitted when the player want to host a game.
# @param(int) port
# @param(string) player_name
signal host_game

# join_game is emitted when the player want to join a game.
# @param(string) address
# @param(string) player_name
signal join_game

onready var PlayerNameLineEdit = $"Player Name Line Edit"
onready var IPAddressConnectLineEdit = $"IP Address Line Edit"

# @driven(signal)
func on_host_button_pressed():
	var player_name = PlayerNameLineEdit.text if PlayerNameLineEdit.text != "" else "Unnamed Player"
	emit_signal("host_game", 45678, 4, true, player_name)

# @driven(signal)
func on_connect_button_pressed():
	var player_name = PlayerNameLineEdit.text if PlayerNameLineEdit.text != "" else "Unnamed Player"
	var address = IPAddressConnectLineEdit.text.split(":")[0] if IPAddressConnectLineEdit.text != "" else "127.0.0.1"
	var port = int(IPAddressConnectLineEdit.text.split(":")[1] if IPAddressConnectLineEdit.text != "" else "45678")
	emit_signal("join_game", address, port, player_name)