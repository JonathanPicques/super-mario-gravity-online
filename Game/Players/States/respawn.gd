extends FiniteStateMachineStateNode

onready var RespawnTimer: Timer = $Timer

func _ready():
	set_process(false)

func _process(delta: float):
	if not RespawnTimer.is_stopped():
		context.PlayerSprite.self_modulate.a = cos(RespawnTimer.time_left * 24.0)

func start_state():
	set_process(true)
	context.set_animation("respawn")

func process_state(delta: float):
	if context.is_animation_finished():
		context.is_invincible += 1
		context.PlayerCollisionBody.set_deferred("disabled", false)
		RespawnTimer.start()
		return fsm.states.stand

func on_timer_timeout():
	context.PlayerSprite.self_modulate.a = 1.0
	context.is_invincible -= 1
	set_process(false)
