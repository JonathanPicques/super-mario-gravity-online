extends Node2D

onready var RespawnTimer = $Timer

func _ready():
	randomize()
	var offset := rand_range(0, 3)
	$AnimatedSprite.flip_v = rand_range(0, 1) > 0.5
	$AnimatedSprite.flip_h = rand_range(0, 1) > 0.5
	$AnimatedSprite.set_frame(offset)
	$AnimatedSprite.play("Appear")

func _process(delta: float):
	if $AnimatedSprite.animation == "Appear" and animation_finished("Appear"):
		$AnimatedSprite.play("Idle")
	if visible and $AnimatedSprite.animation == "Disappear" and animation_finished("Disappear"):
		visible = false
		RespawnTimer.start()

func _on_Area2D_body_entered(player_node: PlayerNode):
	if not player_node.power_node:
		player_node.grab_power(randi() % PowersManager.Powers.size())
		$AnimatedSprite.play("Disappear")

func _on_Timer_timeout():
	visible = true
	print("Reappear")
	$AnimatedSprite.play("Appear")

func animation_finished(name: String):
	return $AnimatedSprite.frame == $AnimatedSprite.get_sprite_frames().get_frame_count(name) - 1

func get_map_data() -> Dictionary:
	return {
		"type": "PowerBox",
		"position": [position.x, position.y]
	}

func load_map_data(item_data):
	position.x = item_data["position"][0]
	position.y = item_data["position"][1]

func quadtree_item_rect() -> Rect2:
	return Rect2(position, Vector2(16, 16))
