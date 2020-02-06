extends Node
class_name QuadtreeNode

var items := []

# add_item adds an item, the item must override quadtree_item_rect.
# @impure
func add_item(new_item: Node):
	if get_item(new_item.quadtree_item_rect().position) == null:
		items.append(new_item)

# @pure
func get_item(position: Vector2):
	for item in items:
		var item_rect: Rect2 = item.quadtree_item_rect()
		var item_size := item_rect.size
		var item_position := item_rect.position
		if (position.x > item_position.x and position.x < item_position.x + item_size.x and
			position.y > item_position.y and position.y < item_position.y + item_size.y):
			return item
	return null

# @impure
func erase_item(position: Vector2):
	var item = get_item(position)
	if item == null:
		return null
	items.erase(item)
	return item

# @impure
func add_items(new_items: Array):
	for item in new_items:
		add_item(item)
