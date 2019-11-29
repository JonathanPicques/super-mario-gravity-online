extends Node2D

onready var Effect = preload("res://Game/Items/ObjectBox/CollectedEffect.tscn")

func _on_Area2D_body_entered(body):
	if body.current_object == null:
		body.get_object()
		var effect_node = Effect.instance()
		effect_node.position = $EffectPosition.global_position
		get_parent().add_child(effect_node)
		queue_free()
