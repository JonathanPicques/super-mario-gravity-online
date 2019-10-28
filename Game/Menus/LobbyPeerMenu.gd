extends Control

const CharacterSelect: Texture = preload("res://Game/Menus/Textures/CharacterSelect.png")
const CharacterSelectDisabled: Texture = preload("res://Game/Menus/Textures/CharacterSelectDisabled.png")

onready var Game = get_tree().get_root().get_node("Game")

const FullOpaque = Color(1, 1, 1, 1)
const HalfOpaque = Color(1, 1, 1, 0.5)

var peer = null

# change peer player.
# @driven(lifecycle)
func _process(delta):
	var peer_id = get_tree().get_network_unique_id()
	if peer != null and peer.id == peer_id:
		if Input.is_action_just_pressed("ui_left"):
			# cycle player skins to the left.
			Game.rpc("net_peer_lobby_update", peer.id, false, (peer.player_id - 1) % Game.Players.size())
		elif Input.is_action_just_pressed("ui_right"):
			# cycle player skins to the right.
			Game.rpc("net_peer_lobby_update", peer.id, false, (peer.player_id + 1) % Game.Players.size())
		elif Input.is_action_just_pressed("ui_accept"):
			# toggle peer ready status.
			Game.rpc("net_peer_lobby_update", peer.id, not peer.ready, peer.player_id)

# set_peer sets the lobby peer menu or empties it.
# @impure
func set_peer(new_peer):
	var peer_id = get_tree().get_network_unique_id()
	peer = new_peer
	$PeerName.visible = peer != null
	$HostCrown.visible = peer != null and peer.id == 1
	$Background.texture = CharacterSelect if peer != null else CharacterSelectDisabled
	$CharacterSprite.visible = peer != null
	$NextCharacterLeft.visible = peer != null and peer.id == peer_id
	$NextCharacterRight.visible = peer != null and peer.id == peer_id
	if peer != null:
		$PeerName.text = peer.name
		$CharacterSprite.texture = load(Game.Players[peer.player_id].preview_path)
		$CharacterSprite.self_modulate = HalfOpaque if not peer.ready else FullOpaque