extends Control

signal stop_game # ()

onready var Game = get_tree().get_root().get_node("Game")
onready var LobbyPeers = [
	$LobbyPeerMenu1,
	$LobbyPeerMenu2,
	$LobbyPeerMenu3,
	$LobbyPeerMenu4,
	$LobbyPeerMenu5,
	$LobbyPeerMenu6,
]

func _ready():
	# connect peer signals to update lobby
	Game.connect("selected_player", self, "update_lobby", [])
	Game.connect("peer_registered", self, "update_lobby", [])
	Game.connect("peer_disconnected", self, "update_lobby", [])
	Game.connect("peer_selected_player", self, "update_lobby", [])
	# update lobby for the first time
	update_lobby()

# update_lobby set the peers in the lobby peer boxes.
# @impure
func update_lobby(a = null, b = null, c = null):
	var peers = Game.get_all_peers()
	for lobby_peer in LobbyPeers:
		lobby_peer.set_peer(null)
	for peer_id in peers:
		var peer = peers[peer_id]
		var lobby_peer = LobbyPeers[peer.index]
		lobby_peer.set_peer(peer)

# @driven(signal)
func on_cancel_button_pressed():
	emit_signal("stop_game")