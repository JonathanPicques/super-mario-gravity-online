extends Node2D

onready var Game = get_node("/root/Game")

enum BlockColor {
	Blue,
	Red,
	Pink,
	Orange
}

export(BlockColor) var color: int = BlockColor.Blue

const OnTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOn.png")
const OffTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOff.png")


func _ready():
	$Sprite.texture = OffTexture
	Game.GameConst.replace_skin($Sprite, color)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	Game.GameMode.connect("item_color_switch_trigger", self, "on_trigger")

func on_trigger(switch_color: int):
	if switch_color == color:
		$Sprite.texture = OnTexture
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	else:
		$Sprite.texture = OffTexture
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
