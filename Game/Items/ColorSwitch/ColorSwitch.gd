extends Node2D

onready var Game = get_node("/root/Game")

enum BlockColor {
	Blue,
	Green,
	Red,
	Yellow
}

var color: int = BlockColor.Blue
var is_on = false

const OnTextures = [
	preload("res://Game/Items/ColorSwitch/Textures/SwitchBlueOn.png"),
	preload("res://Game/Items/ColorSwitch/Textures/SwitchGreenOn.png"),
	preload("res://Game/Items/ColorSwitch/Textures/SwitchRedOn.png"),
	preload("res://Game/Items/ColorSwitch/Textures/SwitchYellowOn.png")
]

const OffTextures = [
	preload("res://Game/Items/ColorSwitch/Textures/SwitchBlueOff.png"),
	preload("res://Game/Items/ColorSwitch/Textures/SwitchGreenOff.png"),
	preload("res://Game/Items/ColorSwitch/Textures/SwitchRedOff.png"),
	preload("res://Game/Items/ColorSwitch/Textures/SwitchYellowOff.png")
]

func _on_Area2D_body_entered(body):
	is_on = !is_on
	$Sprite.texture = OnTextures[color] if is_on else OffTextures[color]
	Game.GameMode.item_color_switch_toggle(is_on, color)
