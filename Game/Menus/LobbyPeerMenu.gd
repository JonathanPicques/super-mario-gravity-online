extends Control

const FullOpaque = Color(1, 1, 1, 1)
const HalfOpaque = Color(1, 1, 1, 0.5)
const CharacterSelect: Texture = preload("res://Game/Menus/Textures/CharacterSelect.png")
const CharacterSelectDisabled: Texture = preload("res://Game/Menus/Textures/CharacterSelectDisabled.png")
onready var Game = get_tree().get_root().get_node("Game")

var peer = null

# change peer player.
# @driven(lifecycle)
func _process(delta):
	if peer != null and peer.id == Game.self_peer.id:
		if Input.is_action_just_pressed("ui_left"):
			# cycle player skins to the left.
			Game.rpc("net_peer_select_player", abs((peer.player_id - 1) % Game.players.size()), false)
		elif Input.is_action_just_pressed("ui_right"):
			# cycle player skins to the right.
			Game.rpc("net_peer_select_player", abs((peer.player_id + 1) % Game.players.size()), false)
		elif Input.is_action_just_pressed("ui_accept"):
			# toggle peer ready status.
			Game.rpc("net_peer_select_player", peer.player_id, not peer.player_ready)

# set_peer sets the lobby peer menu or empties it.
# @impure
func set_peer(new_peer):
	peer = new_peer
	$PeerName.visible = peer != null
	$HostCrown.visible = peer != null and peer.id == 1
	$Background.texture = CharacterSelect if peer != null else CharacterSelectDisabled
	$CharacterSprite.visible = peer != null and peer.player_id != -1
	$NextCharacterLeft.visible = peer != null and peer.id == Game.self_peer.id
	$NextCharacterRight.visible = peer != null and peer.id == Game.self_peer.id
	if peer != null:
		$PeerName.text = peer.name
		$CharacterSprite.texture = load(Game.players[peer.player_id].preview_path)
		$CharacterSprite.self_modulate = HalfOpaque if not peer.player_ready else FullOpaque