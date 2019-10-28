extends "res://Game/Players/Player.gd"

# _ready is called when the player node is ready.
# @driven(lifecycle)
# @impure
func _ready():
	BumpSFX = preload("res://Game/Players/Mario/Sounds/bump.ogg")
	JumpSFX = preload("res://Game/Players/Mario/Sounds/smb_jump.ogg")
	CrouchSFX = preload("res://Game/Players/Mario/Sounds/crouch.ogg")
	WalljumpSFX = preload("res://Game/Players/Mario/Sounds/smas_kick.ogg")
	Step_01_SFX = preload("res://Game/Players/Mario/Sounds/step_default.ogg")
	Step_02_SFX = preload("res://Game/Players/Mario/Sounds/step_default.ogg")