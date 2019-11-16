extends Node2D

onready var Game = get_node("/root/Game")

enum BlockColor {
	Blue,
	Green,
	Red,
	Yellow
}

export var color: int = BlockColor.Blue

const OnTextures = [
	preload("res://Game/Items/ColorSwitch/Textures/BlockBlueOn.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockGreenOn.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockRedOn.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockYellowOn.png")
]

const OffTextures = [
	preload("res://Game/Items/ColorSwitch/Textures/BlockBlueOff.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockGreenOff.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockRedOff.png"),
	preload("res://Game/Items/ColorSwitch/Textures/BlockYellowOff.png")
]

func _ready():
	$Sprite.texture = OffTextures[color]
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	Game.GameMode.connect("item_color_switch_toggle", self, "on_toggle")

func on_toggle(is_on: bool, switch_color: int):
	$Sprite.texture = OnTextures[color] if is_on else OffTextures[color]
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", !is_on)
	
