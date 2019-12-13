extends Node2D

func _ready():
	SkinManager.replace_skin($Sprite, SkinManager.SkinColor.red)
