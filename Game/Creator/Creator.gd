extends Navigation2D

onready var elements := $GUI/Elements.get_children()
onready var CurrentItemSlot := $CurrentItemSlot
onready var ObjectSlot := $ObjectSlot

onready var tilesets = {
	"Wall": [$Map, 13],
	"Sticky": [$Sticky, 8],
	"Oneway": [$Map, 9]
}

var element_index = 0

func _ready():
	$GUI/Elements/ItemButton.grab_focus()
	elements[element_index].attach_creator(self)
	elements[element_index].select_item()


func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	elements[element_index].update_item_placeholder(mouse_position)
	if Input.is_action_pressed("ui_click"):
		elements[element_index].create_item(mouse_position)
	if Input.is_action_pressed("ui_click_bis"):
		elements[element_index].remove_item(mouse_position)

func select_item(index):
	elements[element_index].unselect_item()
	element_index = index
	elements[element_index].attach_creator(self)
	elements[element_index].select_item()

func _on_ItemButton_pressed(): select_item(0)
func _on_ItemButton2_pressed(): select_item(1)
func _on_ItemButton3_pressed(): select_item(2)
func _on_ItemButton4_pressed(): select_item(3)
func _on_ItemButton5_pressed(): select_item(4)
func _on_ItemButton6_pressed(): select_item(5)
func _on_ItemButton7_pressed(): select_item(6)
func _on_ItemButton8_pressed(): select_item(7)
func _on_ItemButton9_pressed(): select_item(8)
func _on_ItemButton10_pressed(): select_item(9)
func _on_ItemButton11_pressed(): select_item(10)
func _on_ItemButton12_pressed(): select_item(11)


func _on_InfoButton_pressed():
	$GUI/InfoBubble.visible = !$GUI/InfoBubble.visible
