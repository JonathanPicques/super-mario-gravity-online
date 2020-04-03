extends Node
class_name PowersManagerNode

const Prince = [
	{
		"scene": preload("res://Game/Powers/PowerPrince.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerPrinceHUD.tscn"),
	},
]

onready var Powers := [
	{
		"scene": preload("res://Game/Powers/PowerSpeed.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerSpeedHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerFireballBasic.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballBasicHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerFireballFollow.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballFollowHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/PowerFireballFollowGhost.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballFollowGhostHUD.tscn"),
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
