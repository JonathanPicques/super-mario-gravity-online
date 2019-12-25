extends "res://Game/Players/Player.gd"

# @impure
func _ready():
	BumpSFX = preload("res://Game/Players/Prince/Sounds/bump.ogg")
	JumpSFX = preload("res://Game/Players/Prince/Sounds/jump.ogg")
	DeathSFX = preload("res://Game/Players/Prince/Sounds/death.ogg")
	WalljumpSFX = preload("res://Game/Players/Prince/Sounds/jump.ogg")
	Step_01_SFX = preload("res://Game/Players/Prince/Sounds/step_01.ogg")
	Step_02_SFX = preload("res://Game/Players/Prince/Sounds/step_02.ogg")
	
	has_trail = true
	speed_multiplier = 2
	is_invincible = true
	has_lifetime = true
	PlayerLifetimeTimer.wait_time = 8
	PlayerLifetimeTimer.start()
