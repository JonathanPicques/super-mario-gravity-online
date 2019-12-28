extends FiniteStateMachineStateNode

var _death_dir := 1.0
var _death_origin := Vector2()

func start_state():
	context.velocity = Vector2(_death_dir * -120.0, -320.0)
	context.start_timer(1.0)
	context.set_animation("death")
	context.play_sound_effect(context.DeathSFX)
	context.PlayerCollisionBody.set_deferred("disabled", true)

func process_state(delta: float):
	context.rotation -= 2.0 * _death_dir * delta
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED, context.GRAVITY_ACCELERATION)
	if context.is_timer_finished():
		context.rotation = 0.0
		context.position = context.last_safe_position
		context.velocity = Vector2()
		return fsm.states.respawn
