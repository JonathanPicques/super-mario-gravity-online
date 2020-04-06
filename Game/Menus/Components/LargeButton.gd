extends TextureButton


const MAX_SCALE := Vector2(1.05, 1.05)
const ANIM_DURATION := 0.2
onready var AnimTween = $Tween

func _on_LargeButton_focus_entered():
	AnimTween.remove_all()
	AnimTween.interpolate_property(self, "rect_scale", Vector2.ONE, MAX_SCALE, ANIM_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	AnimTween.start()

func _on_LargeButton_focus_exited():
	AnimTween.remove_all()
	AnimTween.interpolate_property(self, "rect_scale", MAX_SCALE, Vector2.ONE, ANIM_DURATION, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	AnimTween.start()


