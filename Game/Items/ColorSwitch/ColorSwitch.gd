extends Node2D

onready var Game = get_node("/root/Game")

enum BlockColor {
	Blue,
	Green,
	Red,
	Yellow
}

export var color: int = BlockColor.Blue
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

func _ready():
	$Sprite.texture = OnTextures[color] if is_on else OffTextures[color]
	Game.GameMode.connect("item_color_switch_trigger", self, "on_trigger")

func _on_Area2D_body_entered(body):
	if !is_on:
		Game.GameMode.item_color_switch_trigger(color)

func on_trigger(switch_color: int):
	if switch_color == color:
		is_on = true
		$Sprite.texture = OnTextures[color]
	else:
		is_on = false
		$Sprite.texture = OffTextures[color]
