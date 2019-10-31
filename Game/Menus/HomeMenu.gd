extends Control

# host_game is emitted when the peer wants to host a game.
# @param(int) port
# @param(string) peer_name
signal host_game

# join_game is emitted when the peer wants to join a game.
# @param(string) address
# @param(string) peer_name
signal join_game

const peer_file_name_path = "user://peer_name.txt"
onready var PeerNameLineEdit: LineEdit = $"Peer Name Line Edit"
onready var IPAddressConnectLineEdit: LineEdit = $"IP Address Line Edit"

# _ready is called when the HomeMenu node is ready to load the saved peer name.
# driven(lifecycle)
# @impure
func _ready():
	var peer_name_file = File.new()
	peer_name_file.open(peer_file_name_path, File.READ)
	PeerNameLineEdit.text = peer_name_file.get_line()
	peer_name_file.close()

# @driven(signal)
# @impure
func on_host_button_pressed():
	var addr = IPAddressConnectLineEdit.text.split(":")[0] if IPAddressConnectLineEdit.text != "" else "127.0.0.1"
	var port = int(IPAddressConnectLineEdit.text.split(":")[1] if IPAddressConnectLineEdit.text != "" else "45678")
	var peer_name = PeerNameLineEdit.text if PeerNameLineEdit.text != "" else "Unnamed Player"
	emit_signal("host_game", addr, port, peer_name)

# @driven(signal)
# @impure
func on_connect_button_pressed():
	var addr = IPAddressConnectLineEdit.text.split(":")[0] if IPAddressConnectLineEdit.text != "" else "127.0.0.1"
	var port = int(IPAddressConnectLineEdit.text.split(":")[1] if IPAddressConnectLineEdit.text != "" else "45678")
	var peer_name = PeerNameLineEdit.text if PeerNameLineEdit.text != "" else "Unnamed Player"
	emit_signal("join_game", addr, port, peer_name)

# on_player_name_text_entered is called whenever the player name changes and saves it.
# @driven(signal)
# @impure
func on_peer_name_text_entered(player_name_text):
	var peer_name_file = File.new()
	peer_name_file.open(peer_file_name_path, File.WRITE)
	peer_name_file.store_line(player_name_text)
	peer_name_file.close()