extends TextureButton

func quadtree_item_rect() -> Rect2:
	return Rect2(rect_position, rect_size)

# Scale transition

const MAX_SCALE := Vector2(1.1, 1.1)
const ANIM_DURATION := 0.2
onready var AnimTween = $Tween

func _on_BigButton_focus_entered():
	AnimTween.remove_all()
	AnimTween.interpolate_property(self, "rect_scale", Vector2.ONE, MAX_SCALE, ANIM_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	AnimTween.start()

func _on_BigButton_focus_exited():
	AnimTween.remove_all()
	AnimTween.interpolate_property(self, "rect_scale", MAX_SCALE, Vector2.ONE, ANIM_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	AnimTween.start()

func _on_SmallButton_focus_entered():
	AnimTween.remove_all()
	AnimTween.interpolate_property(self, "rect_scale", Vector2.ONE, MAX_SCALE, ANIM_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	AnimTween.start()


func _on_SmallButton_focus_exited():
	AnimTween.remove_all()
	AnimTween.interpolate_property(self, "rect_scale", MAX_SCALE, Vector2.ONE, ANIM_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	AnimTween.start()

