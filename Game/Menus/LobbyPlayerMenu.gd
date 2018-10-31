tool
extends Control

const CharacterSelect = preload("res://Game/Menus/Textures/CharacterSelect.png")
const CharacterSelectDisabled = preload("res://Game/Menus/Textures/CharacterSelectDisabled.png")

export var host = false
export var joined = false
export var self_player = false

func _process(delta):
	$Background.texture = CharacterSelect if joined else CharacterSelectDisabled
	$HostCrown.visible = joined and host
	$PlayerName.visible = joined
	$CharacterSprite.visible = joined
	$NextCharacterLeft.visible = joined and self_player
	$NextCharacterRight.visible = joined and self_player