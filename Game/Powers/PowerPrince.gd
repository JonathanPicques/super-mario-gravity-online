extends PowerNode
class_name PowerPrinceNode

onready var SpeedTimer: Timer = $Timer

# @impure
# @override
func start_power():
	player_node.set_transformation(MultiplayerManager.PlayerTransformationType.Prince)
#	player_node.has_trail += 1
#	player_node.is_invincible += 1
#	player_node.speed_multiplier = 1.5
	SpeedTimer.start()

# @impure
# @override
func process_power(delta: float):
	set_hud_progress(SpeedTimer.time_left / SpeedTimer.wait_time)
	return SpeedTimer.is_stopped()

# @impure
# @override
func finish_power():
	player_node.set_transformation(MultiplayerManager.PlayerTransformationType.Frog)
#	player_node.has_trail -= 1
#	player_node.is_invincible -= 1
#	player_node.speed_multiplier = 1.0
