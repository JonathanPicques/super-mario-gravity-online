extends PowerNode
class_name ObjectWaveDistortNode

onready var PowerTimer: Timer = $Timer

# @impure
# @override
func start_power():
	PowerTimer.start()
	Game.game_mode_node.apply_split_screen_effect(player_node.player.id, true)

# @impure
# @override
func process_power(delta: float):
	set_hud_progress(PowerTimer.time_left / PowerTimer.wait_time)
	return PowerTimer.is_stopped()

# @impure
# @override
func finish_power():
	Game.game_mode_node.apply_split_screen_effect(player_node.player.id, false)

