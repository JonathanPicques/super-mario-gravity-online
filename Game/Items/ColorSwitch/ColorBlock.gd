extends Node2D

onready var Game = get_node("/root/Game")

export(GameConst.SkinColor) var color: int = GameConst.SkinColor.red

const OnTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOn.png")
const OffTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOff.png")

func _ready():
	Game.GameMode.connect("item_color_switch_trigger", self, "on_trigger")
	Game.GameConst.replace_skin($Sprite, color)
	$Sprite.texture = OffTexture
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)

func on_trigger(switch_color: int):
	if switch_color == color:
		$Sprite.texture = OnTexture
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	else:
		$Sprite.texture = OffTexture
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
