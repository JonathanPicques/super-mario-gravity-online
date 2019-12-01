extends Node2D

onready var Game = get_node("/root/Game")

export(GameConst.SkinColor) var color: int = GameConst.SkinColor.red
var is_on = false

const OnTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOn.png")
const OffTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOff.png")

# @impure
func _ready():
	$Sprite.texture = OnTexture if is_on else OffTexture
	Game.GameConst.replace_skin($Sprite, color)
	Game.GameMode.connect("item_color_switch_trigger", self, "on_trigger")

# @impure
func _on_Area2D_body_entered(player_node):
	if player_node.state == player_node.PlayerState.wallslide or player_node.state == player_node.PlayerState.fall:
		if !is_on:
			Game.GameMode.item_color_switch_trigger(color)

# @impure
func on_trigger(switch_color: int):
	if switch_color == color:
		is_on = true
		$Sprite.texture = OnTexture
	else:
		is_on = false
		$Sprite.texture = OffTexture
