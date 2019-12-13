extends Node
class_name SkinManagerNode

enum SkinColor {
	red,
	blue,
	pink,
	orange
}

const Steel = [
	Color("#46455b"),
	Color("#62677b"),
	Color("#868e9a"),
	Color("#b0bcc4"),
]

const Palettes = {
	SkinColor.red: [
		Color("#9c1b4d"),
		Color("#cc3048"),
		Color("#e44a4a"),
		Color("#ea6262")
	],
	SkinColor.blue: [
		Color("#1e8db4"),
		Color("#48bae3"),
		Color("#6cdaf1"),
		Color("#adf7fa")
	],
	SkinColor.pink: [
		Color("#b45ac3"),
		Color("#d57be5"),
		Color("#ec94e2"),
		Color("#ffcbf9")
	],
	SkinColor.orange: [
		Color("#d3612b"),
		Color("#e78e3f"),
		Color("#e79955"),
		Color("#f2bd7f")
	]
}

const FrogSkins = [
	Color("#076029"),
	Color("#28860F"),
	Color("#72A11D"),
	Color("#A4CC42"),
]

onready var SkinMaterials = {
	SkinColor.red: preload("res://Game/Effects/Materials/SkinMaterial.tres"),
	SkinColor.blue: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate(),
	SkinColor.pink: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate(),
	SkinColor.orange: preload("res://Game/Effects/Materials/SkinMaterial.tres").duplicate()
}

# @impure
func _ready():
	replace_skin_material(SkinMaterials[SkinColor.red], SkinColor.red)
	replace_skin_material(SkinMaterials[SkinColor.blue], SkinColor.blue)
	replace_skin_material(SkinMaterials[SkinColor.pink], SkinColor.pink)
	replace_skin_material(SkinMaterials[SkinColor.orange], SkinColor.orange)

# @impure
func replace_skin(spriteOrTexture, skin_color: int, is_steel := false):
	if is_steel:
		spriteOrTexture.material = SkinMaterials[skin_color].duplicate()
		replace_skin_material(spriteOrTexture.material, skin_color, is_steel)
	else:
		spriteOrTexture.material = SkinMaterials[skin_color]

# @impure
func replace_skin_material(sprite_material: Material, skin_color: int, is_steel := false):
	sprite_material.set_shader_param("color0", Palettes[skin_color][0])
	sprite_material.set_shader_param("color1", Palettes[skin_color][1])
	sprite_material.set_shader_param("color2", Palettes[skin_color][2])
	sprite_material.set_shader_param("color3", Palettes[skin_color][3])
	
	sprite_material.set_shader_param("skin_color0", Steel[0] if is_steel else FrogSkins[0])
	sprite_material.set_shader_param("skin_color1", Steel[1] if is_steel else FrogSkins[1])
	sprite_material.set_shader_param("skin_color2", Steel[2] if is_steel else FrogSkins[2])
	sprite_material.set_shader_param("skin_color3", Steel[3] if is_steel else FrogSkins[3])
