extends Node2D

export(SkinManagerNode.SkinColor) var color: int = SkinManagerNode.SkinColor.aqua
var is_on = false

const OnTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOn.png")
const OffTexture = preload("res://Game/Items/ColorSwitch/Textures/ColorSwitchOff.png")

# @impure
func _ready():
	$Sprite.texture = OnTexture if is_on else OffTexture
	if Game.game_mode_node:
		Game.game_mode_node.connect("item_color_switch_trigger", self, "on_trigger")
	SkinManager.replace_skin($Sprite, color)

# @impure
func _on_Area2D_body_entered(player_node: PlayerNode):
	if player_node.velocity.y > PlayerNode.FALLING_VELOCITY_THRESHOLD:
		if !is_on:
		 Game.game_mode_node.item_color_switch_trigger(color)

# @impure
func on_trigger(switch_color: int):
	if switch_color == color:
		is_on = true
		$Sprite.texture = OnTexture
	else:
		is_on = false
		$Sprite.texture = OffTexture

func get_map_data() -> Dictionary:
	return {
		"type": "ColorSwitch",
		"color": SkinManager.get_map_data(color),
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	color = SkinManager.load_map_data(item_data["color"])
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]
