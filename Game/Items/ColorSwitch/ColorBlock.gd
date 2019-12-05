extends Node2D

export(GameConstNode.SkinColor) var color: int = GameConstNode.SkinColor.red

const OnTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOn.png")
const OffTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOff.png")

func _ready():
	$Sprite.texture = OffTexture
	Game.game_mode_node.connect("item_color_switch_trigger", self, "on_trigger")
	GameConst.replace_skin($Sprite, color)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)

func on_trigger(switch_color: int):
	if switch_color == color:
		$Sprite.texture = OnTexture
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	else:
		$Sprite.texture = OffTexture
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
