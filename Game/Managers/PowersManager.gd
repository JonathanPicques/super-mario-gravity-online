extends Node
class_name PowersManagerNode

onready var Powers := [
	{
		"scene": preload("res://Game/Powers/Invincibility.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/Speed.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/FireballGhost.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/FireballAuto.tscn"),
	},
	{
		"scene": preload("res://Game/Powers/FireballDumb.tscn"),
	},
]
