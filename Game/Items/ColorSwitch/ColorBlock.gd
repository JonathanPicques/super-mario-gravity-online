extends Node2D

onready var Game = get_node("/root/Game")

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
	Game.GameMode.connect("item_color_switch_toggle", self, "on_toggle_color_block")

func on_toggle_color_block(is_on: bool, color: int):
	$Sprite.texture = OnTextures[color] if is_on else OffTextures[color]
	print("Disable collisions: ", !is_on)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", !is_on)
	
