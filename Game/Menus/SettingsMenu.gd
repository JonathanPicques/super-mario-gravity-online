extends Navigation2D

var current_row = 0

const keys = ["music", "sfx", "minimap"]

onready var labels = [
	$GUI/Row1Label,
	$GUI/Row2Label,
	$GUI/Row3Label
]

onready var toggles = [
	$GUI/Row1Toggle,
	$GUI/Row2Toggle,
	$GUI/Row3Toggle
]

func _ready():
	AudioManager.play_music("res://Game/Menus/Musics/Awkward-Princesss-Day-Out.ogg")
	refresh_labels_color()
	for i in range(0, toggles.size()):
		toggles[i].text = str(SettingsManager.values[keys[i]])

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
		toggle_label()	

# @impure
func refresh_labels_color():
	var i = 0
	for i in range(0, labels.size()):
		labels[i].set("custom_colors/font_color", Color("#1B192C" if i != current_row else "#2CB274"))
		toggles[i].set("custom_colors/font_color", Color("#1B192C" if i != current_row else "#2CB274"))
		i += 1

# @impure
func toggle_label():
	var value = int(toggles[current_row].text)
	var new_value = value + 1 if value < 5 else 0
	toggles[current_row].text = str(new_value)
	SettingsManager.values[keys[current_row]] = new_value
	if keys[current_row] == "sfx":
		pass
	SettingsManager.apply_settings()


func _on_Map_tree_exited():
	SettingsManager.save_settings()
