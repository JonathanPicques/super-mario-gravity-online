extends Navigation2D

var current_row = 0

const keys = ["music", "sfx", "minimap"]
const types = ["range", "range", "toggle"]

onready var labels = [
	$GUI/Row1Label,
	$GUI/Row2Label,
	$GUI/Row3Label
]

onready var values = [
	$GUI/Row1Toggle,
	$GUI/Row2Toggle,
	$GUI/Row3Toggle
]

func _ready():
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	refresh_labels_color()
	for i in range(0, values.size()):
		if types[i] == "range":
			values[i].text = str(SettingsManager.values[keys[i]])
		elif types[i] == "toggle":
			values[i].text = "On" if SettingsManager.values[keys[i]] else "Off"
			
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_home_menu_scene()
	if Input.is_action_just_pressed("ui_up") and current_row > 0:
		current_row -= 1
		refresh_labels_color()
	if Input.is_action_just_pressed("ui_down") and current_row < 2:
		current_row += 1
		refresh_labels_color()
	if Input.is_action_just_pressed("ui_accept"):
		update_value()	

# @impure
func refresh_labels_color():
	for i in range(0, labels.size()):
		labels[i].set("custom_colors/font_color", Color("#1B192C" if i != current_row else "#2CB274"))
		values[i].set("custom_colors/font_color", Color("#1B192C" if i != current_row else "#2CB274"))

# @impure
func update_value():
	var new_value
	if types[current_row] == "range":
		var value = int(values[current_row].text)
		new_value = value + 1 if value < 5 else 0
		values[current_row].text = str(new_value)
	elif types[current_row] == "toggle":
		var value = values[current_row].text == "On"
		new_value = !value
		values[current_row].text = "On" if new_value else "Off"
	SettingsManager.values[keys[current_row]] = new_value
	SettingsManager.apply_settings()

func _on_Map_tree_exited():
	SettingsManager.save_settings()
