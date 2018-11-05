extends Control

# stop_game is emitted when cancel button is pressed.
signal stop_game

onready var LobbyPeers = [
	$LobbyPeerMenu1,
	$LobbyPeerMenu2,
	$LobbyPeerMenu3,
	$LobbyPeerMenu4,
	$LobbyPeerMenu5,
	$LobbyPeerMenu6,
]

# set_peers set the peers in the lobby peers boxes.
# @impure
func set_peers(peers: Dictionary):
	for lobby_peer in LobbyPeers:
		lobby_peer.set_peer(null)
	for peer_id in peers:
		var peer = peers[peer_id]
		var lobby_peer = LobbyPeers[peer.index]
		lobby_peer.set_peer(peer)

# @driven(signal)
func on_cancel_button_pressed():
	emit_signal("stop_game")