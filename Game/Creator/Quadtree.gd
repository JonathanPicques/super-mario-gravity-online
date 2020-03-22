extends Node
class_name QuadtreeNode

var items := []

# add_item adds an item, the item must override quadtree_item_rect.
# @impure
func add_item(new_item: Node):
	if get_item(new_item.quadtree_item_rect()) == null:
		items.append(new_item)

# @pure
func get_item(rect: Rect2):
	for item in items:
		var item_rect: Rect2 = item.quadtree_item_rect()
		if true \
			and item_rect.position.x < rect.position.x + rect.size.x \
			and item_rect.position.x + item_rect.size.x > rect.position.x \
			and item_rect.position.y < rect.position.y + rect.size.y  \
			and item_rect.position.y + item_rect.size.y > rect.position.y:
			return item
	return null

# @impure
func erase_item(position: Vector2):
	var item = get_item(Rect2(position, Vector2(16, 16)))
	if item == null:
		return null
	items.erase(item)
	return item

# @impure
func add_items(new_items: Array):
	for item in new_items:
		add_item(item)
