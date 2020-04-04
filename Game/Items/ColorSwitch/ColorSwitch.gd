extends Node2D

export(SkinManagerNode.BlockColor) var color: int = SkinManagerNode.BlockColor.amber
var is_on = false

const OnTextures := [
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnAmber.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnAmethyst.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnDiamond.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnEmerald.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnQuartz.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOnRuby.png"),
]

const OffTextures := [
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffAmber.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffAmethyst.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffDiamond.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffEmerald.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffQuartz.png"),
	preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOffRuby.png"),
]

onready var ItemSprite = $Sprite

# @impure
func _ready():
	ItemSprite.texture = OnTextures[color] if is_on else OffTextures[color]
	if Game.game_mode_node:
		Game.game_mode_node.connect("item_color_switch_trigger", self, "on_trigger")
#	SkinManager.replace_skin(ItemSprite, color)

# @impure
func _on_Area2D_body_entered(player_node: PlayerNode):
	if player_node.velocity.y > PlayerNode.FALLING_VELOCITY_THRESHOLD:
		if !is_on:
		 Game.game_mode_node.item_color_switch_trigger(color)

# @impure
func on_trigger(switch_color: int):
	if switch_color == color:
		is_on = true
		ItemSprite.texture = OnTextures[color]
	else:
		is_on = false
		ItemSprite.texture = OffTextures[color]

func get_map_data() -> Dictionary:
	return {
		"type": "ColorSwitch",
		"color": color,
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	color = int(item_data["color"])
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(16, 16))
