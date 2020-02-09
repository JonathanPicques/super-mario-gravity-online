extends PlayerNode

# @impure
func _ready():
	BumpSFX = preload("res://Game/Players/Classes/Prince/Sounds/bump.ogg")
	JumpSFX = preload("res://Game/Players/Classes/Prince/Sounds/jump.ogg")
	DeathSFX = preload("res://Game/Players/Classes/Prince/Sounds/death.ogg")
	WalljumpSFX = preload("res://Game/Players/Classes/Prince/Sounds/jump.ogg")
	Step_01_SFX = preload("res://Game/Players/Classes/Prince/Sounds/step_01.ogg")
	Step_02_SFX = preload("res://Game/Players/Classes/Prince/Sounds/step_02.ogg")
	
	has_trail += 1
	is_invincible += 1
	speed_multiplier = 2.0
	PlayerLifetimeTimer.wait_time = 8.0
	PlayerLifetimeTimer.start()
