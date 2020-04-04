extends Sprite

func quadtree_item_rect() -> Rect2:
	return Rect2(position, get_rect().size)
