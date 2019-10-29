extends Node2D

# connect_flag_overlap connects body_entered signal.
# @impure
func connect_flag_overlap(target: Object, method: String):
	$Area2D.connect("body_entered", target, method)