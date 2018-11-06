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

# _ready is called when the HomeMenu node is ready to load the saved player name.
# driven(lifecycle)
func _ready():
	var player_name_file = File.new()
	player_name_file.open("user://player_name.txt", File.READ)
	PlayerNameLineEdit.text = player_name_file.get_line()
	player_name_file.close()

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

# on_player_name_text_entered is called whenever the player name changes and saves it.
# @driven(signal)
func on_player_name_text_entered(player_name_text):
	var player_name_file = File.new()
	player_name_file.open("user://player_name.txt", File.WRITE)
	player_name_file.store_line(player_name_text)
	player_name_file.close()