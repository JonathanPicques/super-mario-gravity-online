extends Node
class_name PowersManagerNode

onready var Powers := [
	{
		"scene": preload("res://Game/Powers/PowerSpeed.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerSpeedHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerFireballBasic.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerFireballFollow.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerFireballFollowGhost.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerWaveDistort.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerWaveDistortHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerInvincibility.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerInvincibilityHUD.tscn"),
	},
]
