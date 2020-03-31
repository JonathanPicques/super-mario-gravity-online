extends Node2D
class_name NPCNode

func on_talk():
	Game.goto_creator_scene()

func _process(delta):
	if $Bubble.visible == false:
		return
	var lead_player = MultiplayerManager.get_lead_player()
	if lead_player and InputManager.is_player_action_just_pressed(lead_player.id, "up"):
		on_talk()

func _on_Area2D_body_entered(body):
	$Bubble.visible = true

func _on_Area2D_body_exited(body):
	$Bubble.visible = false
