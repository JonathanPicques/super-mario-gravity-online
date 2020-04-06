extends TextureButton

func quadtree_item_rect() -> Rect2:
	return Rect2(rect_position, rect_size)

var previous_position := Vector2()

func _on_SmallButton_focus_entered():
	var scale = Vector2(1.1, 1.1)
	var button_size = self.get_size()
	var button_pos = self.rect_global_position
	previous_position = button_pos
	self.set_scale(scale)
	self.set_global_position(button_pos + button_size * (Vector2.ONE - scale) / 2)


func _on_SmallButton_focus_exited():
	var scale = Vector2(1, 1)
	var button_size = self.get_size()
	var button_pos = self.rect_global_position
	
	self.set_scale(scale)
	self.set_global_position(previous_position)


func _on_BigButton_focus_entered():
	var scale = Vector2(1.1, 1.1)
	var button_size = self.get_size()
	var button_pos = self.rect_global_position
	previous_position = button_pos
	self.set_scale(scale)
	self.set_global_position(button_pos + button_size * (Vector2.ONE - scale) / 2)


func _on_BigButton_focus_exited():
	var scale = Vector2(1, 1)
	var button_size = self.get_size()
	var button_pos = self.rect_global_position
	
	self.set_scale(scale)
	self.set_global_position(previous_position)
