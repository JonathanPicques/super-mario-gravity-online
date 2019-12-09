extends Node

var current_amplitude = 0

onready var ParentNode = get_parent()
onready var TweenNode = $ShakeTween
onready var FrequencyNode = $Frenquency
onready var DurationNode = $Duration

func start_shake(duration = 0.1, frequency = 15.0, amplitude = 15.0):
	DurationNode.wait_time = duration
	FrequencyNode.wait_time = 1.0 / frequency
	current_amplitude = amplitude
	DurationNode.start()
	FrequencyNode.start()
	new_shake()

func new_shake():
	var rand = Vector2()
	rand.x = rand_range(-current_amplitude, current_amplitude)
	rand.y = rand_range(-current_amplitude, current_amplitude)

	TweenNode.interpolate_property(
		ParentNode, "offset",
		Vector2.ZERO, rand,
		FrequencyNode.wait_time,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	TweenNode.start()

func reset():
	TweenNode.interpolate_property(
		ParentNode, "offset", Vector2.ZERO, Vector2.ZERO,
		FrequencyNode.wait_time,
		Tween.TRANS_SINE,
		Tween.EASE_OUT
	)
	TweenNode.start()
	FrequencyNode.stop()

func _on_Frenquency_timeout():
	new_shake()


func _on_Duration_timeout():
	reset()
