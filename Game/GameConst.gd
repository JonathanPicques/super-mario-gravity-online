extends Node

enum SkinColor {
	Blue,
	Red,
	Pink,
	Orange
}

var Palettes = {
	SkinColor.Blue: [
		Color("#1e8db4"),
		Color("#48bae3"),
		Color("#6cdaf1"),
		Color("#adf7fa")
	],
	SkinColor.Red: [
		Color("#cd2c46"),
		Color("#adf7fa"),
		Color("#f18c73"),
		Color("#fbbba4")
	],
	SkinColor.Pink: [
		Color("#b45ac3"),
		Color("#d57be5"),
		Color("#ec94e2"),
		Color("#ffcbf9")
	],
	SkinColor.Orange: [
		Color("#d3612b"),
		Color("#e78e3f"),
		Color("#e79955"),
		Color("#f2bd7f")
	]
}

func replace_skin(sprite, skin_color):
	print("Set skin", skin_color)
	sprite.material.set_shader_param("color1", Palettes[skin_color][0])
	sprite.material.set_shader_param("color2", Palettes[skin_color][1])
	sprite.material.set_shader_param("color3", Palettes[skin_color][2])
	sprite.material.set_shader_param("color4", Palettes[skin_color][3])
