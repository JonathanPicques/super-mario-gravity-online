extends Node2D

export(SkinManagerNode.SkinColor) var color: int = SkinManagerNode.SkinColor.aqua

const OnTexture := preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOn.png")
const OffTexture := preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOff.png")

# @impure
func _ready():
	$Sprite.texture = OffTexture
	if Game.game_mode_node:
		Game.game_mode_node.connect("item_color_switch_trigger", self, "on_trigger")
	SkinManager.replace_skin($Sprite, color)
	$StaticBody2D.collision_layer &= ~Game.COLLISION_LAYER_SOLID

# @impure
func on_trigger(switch_color: int):
	if switch_color == color:
		$Sprite.texture = OnTexture
		$StaticBody2D.collision_layer |= Game.COLLISION_LAYER_SOLID
	else:
		$Sprite.texture = OffTexture
		$StaticBody2D.collision_layer &= ~Game.COLLISION_LAYER_SOLID
