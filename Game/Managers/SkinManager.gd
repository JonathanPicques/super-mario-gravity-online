extends Node
class_name SkinManagerNode

enum SkinColor {
	aqua,
	blue,
	pink,
	orange,
	yellow,
	purple,
}

func get_map_data(color: int) -> String:
	match color:
		SkinColor.aqua:
			return "aqua"
		SkinColor.blue:
			return "blue"
		SkinColor.pink:
			return "pink"
		SkinColor.orange:
			return "orange"
		SkinColor.yellow:
			return "yellow"
		SkinColor.purple:
			return "purple"
	return "unknown"

const Steel = [
	Color("#46455b"),
	Color("#62677b"),
	Color("#868e9a"),
	Color("#b0bcc4"),
]

const PrinceSkin = [
	Color("#365729"),
	Color("#5a9244"),
	Color("#5db53b"),
	Color("#7dcd33")
]

const FrogSkins = [
	Color("#076029"),
	Color("#28860F"),
	Color("#72A11D"),
	Color("#A4CC42"),
]

const Palettes = {
	SkinColor.aqua: [ # Red
		Color("#4c1010"),
		Color("#861010"),
		Color("#a51515"),
		Color("#e72f2f")
	],
	SkinColor.blue: [
		Color("#352369"),
		Color("#483db3"),
		Color("#7c8ade"),
		Color("#60b5f0")
	],
	SkinColor.pink: [
		Color("#4a324a"),
		Color("#874d89"),
		Color("#c278bf"),
		Color("#f084ae")
	],
	SkinColor.orange: [ # Cyan
		Color("#226a5d"),
		Color("#62e4c6"),
		Color("#91e2f3"),
		Color("#9afaf6")
	],
	SkinColor.purple: [ # white
		Color("#695d51"),
		Color("#daceb0"),
		Color("#fde8d3"),
		Color("#fff8f1")
	],
	SkinColor.yellow: [ # black
		Color("#181e19"),
		Color("#27392b"),
		Color("#355140"),
		Color("#366649")
	]
}

onready var SkinMaterials = {
	SkinColor.aqua: preload("res://Game/Effects/Materials/SkinMaterial.tres"),
	SkinColor.blue: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate(),
	SkinColor.pink: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate(),
	SkinColor.orange: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate(),
	SkinColor.yellow: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate(),
	SkinColor.purple: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate()
}

# @impure
func _ready():
	replace_skin_material(SkinMaterials[SkinColor.aqua], SkinColor.aqua)
	replace_skin_material(SkinMaterials[SkinColor.blue], SkinColor.blue)
	replace_skin_material(SkinMaterials[SkinColor.pink], SkinColor.pink)
	replace_skin_material(SkinMaterials[SkinColor.orange], SkinColor.orange)
	replace_skin_material(SkinMaterials[SkinColor.yellow], SkinColor.yellow)
	replace_skin_material(SkinMaterials[SkinColor.purple], SkinColor.purple)

# @impure
func replace_skin(spriteOrTexture, skin_color: int, is_steel := false, is_prince := false):
	if is_steel or is_prince:
		spriteOrTexture.material = SkinMaterials[skin_color].duplicate()
		replace_skin_material(spriteOrTexture.material, skin_color, is_steel, is_prince)
	else:
		spriteOrTexture.material = SkinMaterials[skin_color]

# @impure
func replace_skin_material(sprite_material: Material, skin_color: int, is_steel := false, is_prince := false):
	sprite_material.set_shader_param("color0", Palettes[skin_color][0])
	sprite_material.set_shader_param("color1", Palettes[skin_color][1])
	sprite_material.set_shader_param("color2", Palettes[skin_color][2])
	sprite_material.set_shader_param("color3", Palettes[skin_color][3])
	
	if is_prince:
		sprite_material.set_shader_param("skin_color0", PrinceSkin[0])
		sprite_material.set_shader_param("skin_color1", PrinceSkin[1])
		sprite_material.set_shader_param("skin_color2", PrinceSkin[2])
		sprite_material.set_shader_param("skin_color3", PrinceSkin[3])
	else:
		sprite_material.set_shader_param("skin_color0", Steel[0] if is_steel else FrogSkins[0])
		sprite_material.set_shader_param("skin_color1", Steel[1] if is_steel else FrogSkins[1])
		sprite_material.set_shader_param("skin_color2", Steel[2] if is_steel else FrogSkins[2])
		sprite_material.set_shader_param("skin_color3", Steel[3] if is_steel else FrogSkins[3])
