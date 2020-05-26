extends Node
class_name PowersManagerNode

onready var Powers := [
	{
		"name": "windblow",
		"scene": preload("res://Game/Powers/PowerFireballFollow.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballFollowHUD.tscn"),
	},
]

onready var _Powers := [
	{
		"name": "fireball",
		"scene": preload("res://Game/Powers/PowerFireballBasic.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballBasicHUD.tscn"),
	},
	{
		"name": "windblow",
		"scene": preload("res://Game/Powers/PowerFireballFollow.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballFollowHUD.tscn"),
	},
	{
		"name": "thunderblast",
		"scene": preload("res://Game/Powers/PowerFireballFollowGhost.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballFollowGhostHUD.tscn"),
	},
	{
		"name": "speed",
		"scene": preload("res://Game/Powers/PowerSpeed.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerSpeedHUD.tscn"),
	},
	{
		"name": "invincibility",
		"scene": preload("res://Game/Powers/PowerInvincibility.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerInvincibilityHUD.tscn"),
	},
	{
		"name": "prince",
		"scene": preload("res://Game/Powers/PowerPrince.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerPrinceHUD.tscn"),
	},
	{
		"name": "waves",
		"scene": preload("res://Game/Powers/PowerWaveDistort.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerWaveDistortHUD.tscn"),
	},
]
