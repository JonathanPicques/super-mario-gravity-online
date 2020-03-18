extends FiniteStateMachineStateNode

onready var SwimTimer: Timer = $Timer

const BubbleScene := preload("res://Game/Effects/Particles/Bubble.tscn")

func start_state():
	context.set_animation("swim")
	context.PlayerSprite.z_index = -1
	SwimTimer.start()

func process_state(delta: float):
	context.disable_snap = 1.0
	context.handle_swim_move(delta, context.SWIM_MAX_SPEED, context.SWIM_ACCELERATION, context.SWIM_DECELERATION)
	context.handle_direction()
	context.handle_last_safe_position()
	if not context.is_in_water():
		return fsm.states.jump

func finish_state():
	context.PlayerSprite.z_index = 0
	SwimTimer.stop()

func on_timer_timeout():
	# create a bubble sfx
	var bubble_node := BubbleScene.instance()
	bubble_node.position = context.PlayerSprite.get_node("BubbleSpawn").global_position
	Game.map_node.ParticleSlot.add_child(bubble_node)
	# randomize bubble spawn
	SwimTimer.wait_time = rand_range(0.8, 1.2)
