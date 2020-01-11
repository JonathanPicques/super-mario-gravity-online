extends FiniteStateMachineStateNode

var _direction := 0
var _stick_wall := 0.0

func start_state():
	_direction = context.direction
	_stick_wall = 0.0
	context.PlayerSprite.position.x += _direction * 2
	context.velocity.x = 0
	context.velocity.y = context.velocity.y * 0.1
	context.jumps_remaining = context.MAX_JUMPS - 1
	context.fx_hit_wall()
	context.set_animation("wallslide")

func process_state(delta: float):
	context.handle_gravity(delta, context.GRAVITY_MAX_SPEED * 0.5, context.GRAVITY_ACCELERATION * 0.25)
	if context.is_in_water():
		return fsm.states.enter_swim
	if context.is_on_floor():
		context.fx_hit_ground()
		return fsm.states.stand
	if not context.is_on_wall_passive():
		return fsm.states.fall
	if context.input_down_once:
		context.wallslide_cancelled = true
		return fsm.states.fall
	if context.input_jump_once:
		return fsm.states.walljump
	if context.has_invert_direction(context.input_velocity.x, context.direction):
		_stick_wall += delta
		if _stick_wall > context.WALL_SLIDE_STICK_WALL_JUMP:
			context.set_direction(-context.direction)
			return fsm.states.fall

func finish_state():
	context.PlayerSprite.position.x -= _direction * 2
