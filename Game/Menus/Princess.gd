extends Sprite

func _ready():
	print("Princess ready")

func _on_Area2D_area_entered(area):
	print("Enter area")
	get_parent().open_popup()
