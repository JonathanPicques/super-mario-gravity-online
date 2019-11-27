extends Node2D

onready var Game = get_node("/root/Game")

enum BlockColor {
	Red,
	Blue,
	Green,
	Yellow
}

export(BlockColor) var color: int = BlockColor.Blue

const ColorTextures = [
	preload("res://Game/Items/ColorSwitch/Textures/BlockRed.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockBlue.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockGreen.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockYellow.png")
]

func _ready():
	$Sprite.texture = ColorTextures[color]
	$Sprite.modulate.a = 0.4
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	Game.GameMode.connect("item_color_switch_trigger", self, "on_trigger")

func on_trigger(switch_color: int):
	if switch_color == color:
		$Sprite.modulate.a = 1
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	else:
		$Sprite.modulate.a = 0.4
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
