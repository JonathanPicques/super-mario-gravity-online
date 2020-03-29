extends Node
class_name QuadtreeNode

enum Types { node, tile }

var items := [] # either a tile or an object

# add_node adds a node in the quadtree.
# the given node must override quadtree_item_rect() -> Rect2
# @impure
func add_node(node: Node):
	items.push_back({type = Types.node, node = node, rect = node.quadtree_item_rect()})

# add_tile adds a tile at the given position in the quadtree.
# @impure
func add_tile(pos: Vector2):
	items.push_back({type = Types.tile, rect = Rect2(pos, Vector2(MapManager.cell_size, MapManager.cell_size))})

# get_item returns an item if found in the given rect, or null otherwise.
# @pure
func get_item(rect: Rect2):
	for item in items:
		var item_rect: Rect2 = item.rect
		if true \
			and item_rect.position.x < rect.position.x + rect.size.x \
			and item_rect.position.x + item_rect.size.x > rect.position.x \
			and item_rect.position.y < rect.position.y + rect.size.y \
			and item_rect.position.y + item_rect.size.y > rect.position.y:
			return item
	return null

# has_item returns true if found in the given rect, false otherwise
# @pure
func has_item(rect: Rect2) -> bool:
	return get_item(rect) != null

# @impure
func erase_item(position: Vector2):
	var item = get_item(Rect2(position, Vector2(16, 16)))
	if item == null:
		return null
	items.erase(item)
	return item
