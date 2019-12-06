extends "res://Game/Players/Player.gd"

# @impure
func _ready():
	BumpSFX = preload("res://Game/Players/Frog/Sounds/bump.ogg")
	JumpSFX = preload("res://Game/Players/Frog/Sounds/jump.ogg")
	DeathSFX = preload("res://Game/Players/Frog/Sounds/death.ogg")
	WalljumpSFX = preload("res://Game/Players/Frog/Sounds/jump.ogg")
	Step_01_SFX = preload("res://Game/Players/Frog/Sounds/step_01.ogg")
	Step_02_SFX = preload("res://Game/Players/Frog/Sounds/step_02.ogg")
