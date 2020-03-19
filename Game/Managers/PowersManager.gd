extends Node
class_name PowersManagerNode

onready var Powers := [
	# {
	# 	"scene": preload("res://Game/Powers/PowerSpeed.tscn"),
	# 	"hud_scene": preload("res://Game/Powers/PowerSpeedHUD.tscn"),
	# },
	{
		"scene": preload("res://Game/Powers/PowerFireball.tscn"),
		"hud_scene": preload("res://Game/Powers/PowerFireballHUD.tscn"),
	},
	# {
	# 	"scene": preload("res://Game/Powers/PowerWaveDistort.tscn"),
	# 	"hud_scene": preload("res://Game/Powers/PowerWaveDistortHUD.tscn"),
	# },
	# {
	# 	"scene": preload("res://Game/Powers/PowerInvincibility.tscn"),
	# 	"hud_scene": preload("res://Game/Powers/PowerInvincibilityHUD.tscn"),
	# },
]
