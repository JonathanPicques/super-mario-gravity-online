extends Navigation2D

var current_item = null

func select_item(item_type):
	if item_type == "Tileset":
		return
	current_item = MapManager.create_item(item_type)
	current_item.modulate = Color(1, 1, 1, 0.5)
	$CurrentItemSlot.add_child(current_item)	

func create_item(item_type, mouse_position):
	if item_type == "Tileset":
		var x = round((mouse_position[0] - 8) / 16)
		var y = round((mouse_position[1] - 8) / 16)
		$Map.set_cell(x, y, 13)
		$Map.update_bitmask_area(Vector2(x, y))
	else:
		var item = MapManager.create_item(item_type)
		item.position = current_item.position
		$ObjectSlot.add_child(item)

func _ready():
	$GUI/Items/ItemButton.grab_focus()
	select_item("Tileset")

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	if current_item:
		current_item.position.x = round((mouse_position[0] - 8) / 16) * 16
		current_item.position.y = round((mouse_position[1] - 8)/ 16) * 16
	if Input.is_action_pressed("ui_click"):
		create_item("Tileset", mouse_position)
