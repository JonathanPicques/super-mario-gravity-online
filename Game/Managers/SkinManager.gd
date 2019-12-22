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

const Steel = [
	Color("#46455b"),
	Color("#62677b"),
	Color("#868e9a"),
	Color("#b0bcc4"),
]

const Palettes = {
	SkinColor.aqua: [
		Color("#2987ba"),
		Color("#6cd9f1"),
		Color("#94f1f6"),
		Color("#c2f9f9")
	],
	SkinColor.pink: [
		Color("#db4d9f"),
		Color("#f9a3c5"),
		Color("#ffbcd3"),
		Color("#ffd4d4")
	],
	SkinColor.blue: [
		Color("#3556d4"),
		Color("#8281f0"),
		Color("#97b2f4"),
		Color("#bfd9f6")
	],
	SkinColor.orange: [
		Color("#db5d25"),
		Color("#e68d41"),
		Color("#f0b565"),
		Color("#f6d89f")
	],
	SkinColor.purple: [ # white
		Color("#8caacc"),
		Color("#b4cae3"),
		Color("#d2e0f0"),
		Color("#ffffff")
	],
	SkinColor.yellow: [ # black
		Color("#1a232d"),
		Color("#303943"),
		Color("#5f6a76"),
		Color("#828890")
	]
}

const FrogSkins = [
	Color("#076029"),
	Color("#28860F"),
	Color("#72A11D"),
	Color("#A4CC42"),
]

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
