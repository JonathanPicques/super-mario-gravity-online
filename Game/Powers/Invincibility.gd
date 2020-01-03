extends PowerNode
class_name InvincibilityPowerNodeNode

onready var InvincibilityTimer: Timer = $Timer

# @impure
# @override
func start_power():
	player_node.is_invincible += 1
	SkinManager.replace_skin(player_node.PlayerSprite, player_node.player.skin_id, true)
	InvincibilityTimer.start()

# @impure
# @override
func process_power(delta: float):
	set_hud_progress(InvincibilityTimer.time_left / InvincibilityTimer.wait_time)
	return InvincibilityTimer.is_stopped()

# @impure
# @override
func finish_power():
	player_node.is_invincible -= 1
	SkinManager.replace_skin(player_node.PlayerSprite, player_node.player.skin_id, false)
