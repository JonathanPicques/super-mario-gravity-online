extends Control

const CharacterSelect = preload("res://Game/Menus/Textures/CharacterSelect.png")
const CharacterSelectDisabled = preload("res://Game/Menus/Textures/CharacterSelectDisabled.png")

var peer

func set_peer(new_peer):
	var peer_id = get_tree().get_network_unique_id()
	peer = new_peer
	$PeerName.text = peer.name if peer != null else ""
	$PeerName.visible = peer != null
	$HostCrown.visible = peer != null and peer.id == 1
	$Background.texture = CharacterSelect if peer != null else CharacterSelectDisabled
	$CharacterSprite.visible = peer != null
	$NextCharacterLeft.visible = peer != null and peer.id == peer_id
	$NextCharacterRight.visible = peer != null and peer.id == peer_id