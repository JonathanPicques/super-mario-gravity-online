extends Node2D

export(SkinManagerNode.BlockColor) var color: int = SkinManagerNode.BlockColor.amber

const OnTextures := [
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnAmber.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnAmethyst.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnDiamond.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnEmerald.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnQuartz.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOnRuby.png"),
]

const OffTextures := [
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffAmber.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffAmethyst.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffDiamond.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffEmerald.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffQuartz.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorBlockOffRuby.png"),
]

onready var ItemSprite = $Sprite

# @impure
func _ready():
	if Game.game_mode_node:
		Game.game_mode_node.connect("item_color_switch_trigger", self, "on_trigger")
	ItemSprite.texture = OffTextures[color]
	$StaticBody2D.set_collision_layer_bit(Game.PHYSICS_LAYER_SOLID, false)

# @impure
func on_trigger(switch_color: int):
	if switch_color == color:
		ItemSprite.texture = OnTextures[color]
		$StaticBody2D.set_collision_layer_bit(Game.PHYSICS_LAYER_SOLID, true)
	else:
		ItemSprite.texture = OffTextures[color]
		$StaticBody2D.set_collision_layer_bit(Game.PHYSICS_LAYER_SOLID, false)

func get_map_data() -> Dictionary:
	return {
		"type": "ColorBlock",
		"color": color,
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	color = int(item_data["color"])
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(16, 16))
