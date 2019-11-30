extends Node

enum SkinColor {
	blue,
	red,
	pink,
	orange
}

const Palettes = {
	SkinColor.blue: [
		Color("#1e8db4"),
		Color("#48bae3"),
		Color("#6cdaf1"),
		Color("#adf7fa")
	],
	SkinColor.red: [
		Color("#9c1b4d"),
		Color("#cc3048"),
		Color("#e44a4a"),
		Color("#ea6262")
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

const Steel = [
	Color("#46455b"),
	Color("#62677b"),
	Color("#868e9a"),
	Color("#b0bcc4"),
]

const FrogSkin = [
	Color("#076029"),
	Color("#28860F"),
	Color("#72A11D"),
	Color("#A4CC42"),
]

func replace_skin(sprite, skin_color, is_steel=false):
	sprite.material.set_shader_param("color1", Palettes[skin_color][0])
	sprite.material.set_shader_param("color2", Palettes[skin_color][1])
	sprite.material.set_shader_param("color3", Palettes[skin_color][2])
	sprite.material.set_shader_param("color4", Palettes[skin_color][3])
	
	sprite.material.set_shader_param("skin_color1", Steel[0] if is_steel else FrogSkin[0])
	sprite.material.set_shader_param("skin_color2", Steel[1] if is_steel else FrogSkin[1])
	sprite.material.set_shader_param("skin_color3", Steel[2] if is_steel else FrogSkin[2])
	sprite.material.set_shader_param("skin_color4", Steel[3] if is_steel else FrogSkin[3])
