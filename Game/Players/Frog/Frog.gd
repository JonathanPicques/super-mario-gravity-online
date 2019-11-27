extends "res://Game/Players/Player.gd"

# _ready is called when the player node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	BumpSFX = preload("res://Game/Players/Frog/Sounds/bump.ogg")
	JumpSFX = preload("res://Game/Players/Frog/Sounds/smb_jump.ogg")
	WalljumpSFX = preload("res://Game/Players/Frog/Sounds/smas_kick.ogg")
	Step_01_SFX = preload("res://Game/Players/Frog/Sounds/step_default.ogg")
	Step_02_SFX = preload("res://Game/Players/Frog/Sounds/step_default.ogg")
