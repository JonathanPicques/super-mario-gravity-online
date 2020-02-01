extends Node

var items = []

func add_items(new_items):
	for item in new_items:
		add_item(item)

func add_item(new_item):
	if get_item(new_item.quadtree_item_rect().position) == null:
		items.append(new_item)

func get_item(position):
	for item in items:
		var item_rect = item.quadtree_item_rect()
		var item_position = item_rect.position
		var item_size = item_rect.size
		if (position.x >= item_position.x and position.x <= item_position.x + item_size.x and
			position.y >= item_position.y and position.y <= item_position.y + item_size.y):
			return item
	return null

func erase_item(position):
	var item = get_item(position)
	if item == null:
		return null
	items.erase(item)
	return item
