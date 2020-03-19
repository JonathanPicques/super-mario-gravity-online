extends PowerNode
class_name PowerInvincibilityNode

onready var InvincibilityTimer: Timer = $Timer

const INVINCIBILITY_FRAMES = 18.0 # TODO: get that from sprite

# @impure
# @override
func start_power():
	player_node.is_invincible += 1
	player_node.PlayerInvincibilityEffect.visible = true
	player_node.PlayerInvincibilityEffect.material.set_shader_param("mask_flip", 0 if player_node.direction == 1 else 1)
	player_node.PlayerInvincibilityEffect.material.set_shader_param("mask_offset", INVINCIBILITY_FRAMES / player_node.PlayerSprite.hframes)
	player_node.PlayerInvincibilityEffect.material.set_shader_param("mask_texture", player_node.PlayerSprite.texture)
	SkinManager.replace_skin(player_node.PlayerSprite, player_node.player.skin_id, true)
	InvincibilityTimer.start()

# @impure
# @override
func process_power(delta: float):
	set_hud_progress(InvincibilityTimer.time_left / InvincibilityTimer.wait_time)
	player_node.PlayerInvincibilityEffect.material.set_shader_param("mask_flip", 0 if player_node.direction == 1 else 1)
	player_node.PlayerInvincibilityEffect.material.set_shader_param("mask_offset", INVINCIBILITY_FRAMES / player_node.PlayerSprite.hframes)
	player_node.PlayerInvincibilityEffect.material.set_shader_param("mask_texture", player_node.PlayerSprite.texture)
	return InvincibilityTimer.is_stopped()

# @impure
# @override
func finish_power():
	player_node.is_invincible -= 1
	player_node.PlayerInvincibilityEffect.visible = false
	SkinManager.replace_skin(player_node.PlayerSprite, player_node.player.skin_id, false)
