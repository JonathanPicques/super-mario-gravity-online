extends Node
class_name PowersManagerNode

onready var Powers := [
	{
		"scene": preload("res://Game/Powers/Prince.tscn"),
		"hud": preload("res://Game/Powers/PrinceHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/Invincibility.tscn"),
		"hud": preload("res://Game/Powers/InvincibilityHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/Invincibility.tscn"),
		"hud": preload("res://Game/Powers/InvincibilityHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/Speed.tscn"),
		"hud": preload("res://Game/Powers/SpeedHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/FireballGhost.tscn"),
		"hud": preload("res://Game/Powers/FireballGhostHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/FireballAuto.tscn"),
		"hud": preload("res://Game/Powers/FireballAutoHUD.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/FireballDumb.tscn"),
		"hud": preload("res://Game/Powers/FireballDumbHUD.tscn"),
	},
]
