extends Node
class_name MapManagerNode

var item_scenes = {
	"ColorSwitch": preload("res://Game/Items/ColorSwitch/ColorSwitch.tscn"),
	"ColorBlock": preload("res://Game/Items/ColorSwitch/ColorBlock.tscn"),
	"Door": preload("res://Game/Items/Door/Door.tscn"),
	"PowerBox": preload("res://Game/Items/PowerBox/PowerBox.tscn"),
	"SolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"HSolidBlock": preload("res://Game/Items/SolidBlock/HSolidBlock.tscn"),
	"VSolidBlock": preload("res://Game/Items/SolidBlock/VSolidBlock.tscn"),
	"BigSolidBlock": preload("res://Game/Items/SolidBlock/BigSolidBlock.tscn"),
	"SpikeBall": preload("res://Game/Items/SpikeBall/SpikeBall.tscn"),
	"Spikes": preload("res://Game/Items/Spikes/Spike.tscn"),
	"Trampoline": preload("res://Game/Items/Trampoline/Trampoline.tscn")
}

func create_item(item_type: String) -> Node2D:
	return item_scenes[item_type].instance()
