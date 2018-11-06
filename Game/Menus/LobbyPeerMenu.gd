extends Control

const Players = preload("res://Game/Players/Players.gd")
const CharacterSelect = preload("res://Game/Menus/Textures/CharacterSelect.png")
const CharacterSelectDisabled = preload("res://Game/Menus/Textures/CharacterSelectDisabled.png")

onready var Game = get_tree().get_root().get_node("Game")
onready var PlayerSkins = Players.new().Skins

var peer = null

# change peer player skin.
# @driven(lifecycle)
func _process(delta):
	var peer_id = get_tree().get_network_unique_id()
	if peer != null and peer.id == peer_id:
		if Input.is_action_just_pressed("ui_left"):
			Game.rpc("net_peer_post_configure", peer.id, (peer.player - 1) % PlayerSkins.size(), false)
		elif Input.is_action_just_pressed("ui_right"):
			Game.rpc("net_peer_post_configure", peer.id, (peer.player + 1) % PlayerSkins.size(), false)
		if Input.is_action_just_pressed("ui_accept"):
			Game.rpc("net_peer_post_configure", peer.id, peer.player, not peer.ready)

# set_peer sets the lobby peer menu or empties it.
# @impure
func set_peer(new_peer):
	var peer_id = get_tree().get_network_unique_id()
	peer = new_peer
	$PeerName.text = peer.name if peer != null else ""
	$PeerName.visible = peer != null
	$HostCrown.visible = peer != null and peer.id == 1
	$Background.texture = CharacterSelect if peer != null else CharacterSelectDisabled
	$CharacterSprite.visible = peer != null
	$CharacterSprite.texture = PlayerSkins[peer.player].skin if peer != null else null
	$CharacterSprite.self_modulate = (Color(1, 1, 1, 0.5) if not peer.ready else Color(1, 1, 1, 1)) if peer != null else $CharacterSprite.self_modulate
	$NextCharacterLeft.visible = peer != null and peer.id == peer_id
	$NextCharacterRight.visible = peer != null and peer.id == peer_id