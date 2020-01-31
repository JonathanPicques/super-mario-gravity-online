extends MapNode

onready var Elements := $GUILayer/GUI/Elements.get_children()
onready var CurrentItemSlot := $CurrentItemSlot

onready var WallMap = $Map

onready var tilesets = {
	"Wall": [WallMap, 15, preload("res://Game/Creator/Textures/Icons/WallIcon.png")],
	"Sticky": [$Sticky, 8, preload("res://Game/Creator/Textures/Icons/StickyIcon.png")],
	"Oneway": [WallMap, 9, preload("res://Game/Creator/Textures/Icons/OnewayIcon.png")],
	"Water": [$Water, 14, preload("res://Game/Creator/Textures/Icons/WaterIcon.png")]
}

var element_index = 0

var items_quadtree = []

func _ready():
	$GUILayer/GUI/Elements/ItemButton.grab_focus()
	Elements[element_index].attach_creator(self)
	Elements[element_index].select_item()
	quadtree_init($ObjectSlot)


func quadtree_init(parent):
	for item in parent.get_children():
		items_quadtree.append(item)

func quadtree_append(item):
	items_quadtree.append(item)

func quadtree_get_item_at_position(position):
	for item in items_quadtree:
		print(item.name, " == ", item.ItemSprite.get_rect())

func _process(delta):
	var mouse_position = get_global_mouse_position()
	Elements[element_index].update_item_placeholder(mouse_position)
	if Input.is_action_pressed("ui_click"):
		Elements[element_index].create_item(mouse_position)
	if Input.is_action_pressed("ui_click_bis"):
		quadtree_get_item_at_position(mouse_position)
		Elements[element_index].remove_item(mouse_position)

	if Input.is_action_pressed("ui_left"):
		$Camera2D.translate(Vector2(-16, 0))
	if Input.is_action_pressed("ui_right"):
		$Camera2D.translate(Vector2(16, 0))
	if Input.is_action_pressed("ui_up"):
		$Camera2D.translate(Vector2(0, -16))
	if Input.is_action_pressed("ui_down") and $Camera2D.position.y < 32: # toolbar size
		$Camera2D.translate(Vector2(0, 16))

func select_item(index):
	Elements[element_index].unselect_item()
	element_index = index
	Elements[element_index].attach_creator(self)
	Elements[element_index].select_item()

func _on_InfoButton_pressed():
	$GUILayer/GUI/InfoBubble.visible = !$GUILayer/GUI/InfoBubble.visible

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


func _on_GoToStartButton_pressed():
	$Camera2D.position = $FlagStart.position
	$Camera2D.position.x -= 256
	$Camera2D.position.y -= 144
	if $Camera2D.position.y > 0:
		$Camera2D.position.y = 0

func _on_GoToEndButton_pressed():
	$Camera2D.position = $FlagEnd.position
	$Camera2D.position.x -= 256
	$Camera2D.position.y -= 144
	if $Camera2D.position.y > 0:
		$Camera2D.position.y = 0
