extends GameModeNode

onready var Elements := $GUILayer/GUI/Elements.get_children()
onready var CreatorCamera := $GridContainer/Control1/ViewportContainer1/Viewport1/Camera2D
onready var CurrentItemSlot := $CurrentItemSlot

onready var tilesets = {}

var element_index = 0
var is_select_mode = true

onready var Quadtree = $Quadtree
onready var HUDQuadtree = $HUDQuadtree

onready var TopButtons := [
	$GUILayer/GUI/TopBar/PlayButton,
	$GUILayer/GUI/TopBar/GoToStartButton,
	$GUILayer/GUI/TopBar/GoToEndButton,
	$GUILayer/GUI/TopBar/UndoButton,
	$GUILayer/GUI/TopBar/RedoButton,
	$GUILayer/GUI/TopBar/InfoButton,
	$GUILayer/GUI/TopBar/SettingsButton
]
onready var ItemButtons := $GUILayer/GUI/Elements.get_children()

func _ready():
	set_process(false)

func init():
	# load map
	yield(load_map(""), "completed")
	# remove popup
	$Popup.queue_free()
	remove_child($Popup)
	#
	tilesets = {
		"Wall": [map_node.Map, 15, preload("res://Game/Creator/Textures/Icons/WallIcon.png")],
		"Sticky": [map_node.Sticky, 8, preload("res://Game/Creator/Textures/Icons/StickyIcon.png")],
		"Oneway": [map_node.Map, 9, preload("res://Game/Creator/Textures/Icons/OnewayIcon.png")],
		"Water": [map_node.Water, 14, preload("res://Game/Creator/Textures/Icons/WaterIcon.png")]
	}

func start():
	set_process(true)
	setup_split_screen()
	$GUILayer/GUI/Elements/ItemButton.grab_focus()
	Elements[element_index].attach_creator(self)
	Elements[element_index].select_item()
	
	Quadtree.add_items(map_node.ObjectSlot.get_children())
	for btn in TopButtons:
		HUDQuadtree.add_item(btn)
	HUDQuadtree.add_item($GUILayer/GUI/ElementsBar) # FIXME not working
	
	set_focus_neighbours()

func set_focus_neighbours():
	var i = 0
	for item_button in ItemButtons:
		if i == 0:
			item_button.set("focus_neighbour_left", TopButtons[TopButtons.size() - 1].get_path())
			item_button.set("focus_neighbour_previous", TopButtons[TopButtons.size() - 1].get_path())
			item_button.set("focus_neighbour_right", ItemButtons[i + 1].get_path())
			item_button.set("focus_neighbour_next", ItemButtons[i + 1].get_path())
		elif i == ItemButtons.size() - 1:
			item_button.set("focus_neighbour_left", ItemButtons[i - 1].get_path())
			item_button.set("focus_neighbour_previous", ItemButtons[i - 1].get_path())
			item_button.set("focus_neighbour_right", TopButtons[0].get_path())
			item_button.set("focus_neighbour_next", TopButtons[0].get_path())
		else:
			item_button.set("focus_neighbour_left", ItemButtons[i - 1].get_path())
			item_button.set("focus_neighbour_previous", ItemButtons[i - 1].get_path())
			item_button.set("focus_neighbour_right", ItemButtons[i + 1].get_path())
			item_button.set("focus_neighbour_next", ItemButtons[i + 1].get_path())
		item_button.set("focus_neighbour_top", TopButtons[0].get_path())
		item_button.set("focus_neighbour_bottom", item_button.get_path())
		i += 1
	i = 0
	for top_button in TopButtons:
		if i == 0:
			top_button.set("focus_neighbour_left", ItemButtons[ItemButtons.size() - 1].get_path())
			top_button.set("focus_neighbour_previous", ItemButtons[ItemButtons.size() - 1].get_path())
			top_button.set("focus_neighbour_right", TopButtons[i + 1].get_path())
			top_button.set("focus_neighbour_next", TopButtons[i + 1].get_path())
		elif i == TopButtons.size() - 1:
			top_button.set("focus_neighbour_left", TopButtons[i - 1].get_path())
			top_button.set("focus_neighbour_previous", TopButtons[i - 1].get_path())
			top_button.set("focus_neighbour_right", ItemButtons[0].get_path())
			top_button.set("focus_neighbour_next", ItemButtons[0].get_path())
		else:
			top_button.set("focus_neighbour_left", TopButtons[i - 1].get_path())
			top_button.set("focus_neighbour_previous", TopButtons[i - 1].get_path())
			top_button.set("focus_neighbour_right", TopButtons[i + 1].get_path())
			top_button.set("focus_neighbour_next", TopButtons[i + 1].get_path())
		top_button.set("focus_neighbour_top", top_button.get_path())
		top_button.set("focus_neighbour_bottom", ItemButtons[0].get_path())
		i += 1

func change_select_mode(mode):
	if is_select_mode == mode:
		return
	is_select_mode = mode
	$GUILayer/GUI/ModeLabel.text = "(ESC) select items" if !is_select_mode else "(ESC) move map"
	if !is_select_mode:
		for btn in ItemButtons:
			btn.release_focus()
		for btn in TopButtons:
			btn.release_focus()
	else:
		ItemButtons[element_index].grab_focus()

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	Elements[element_index].update_item_placeholder(mouse_position)
	if Input.is_action_pressed("ui_click"):
		Elements[element_index].create_item(mouse_position)
	if Input.is_action_pressed("ui_click_bis"):
		Elements[element_index].remove_item(mouse_position)
	if Input.is_action_just_pressed("ui_cancel"):
		change_select_mode(!is_select_mode)

	if !is_select_mode:
		if Input.is_action_pressed("ui_left"):
			CreatorCamera.translate(Vector2(-16, 0))
		if Input.is_action_pressed("ui_right"):
			CreatorCamera.translate(Vector2(16, 0))
		if Input.is_action_pressed("ui_up"):
			CreatorCamera.translate(Vector2(0, -16))
		if Input.is_action_pressed("ui_down") and CreatorCamera.position.y < 32: # toolbar size
			CreatorCamera.translate(Vector2(0, 16))

func select_item(index):
	change_select_mode(true)
	Elements[element_index].unselect_item()
	element_index = index
	Elements[element_index].attach_creator(self)
	Elements[element_index].select_item()

func _on_ItemButton_pressed(): select_item(0)
func _on_ItemButton2_pressed(): select_item(1)
func _on_ItemButton3_pressed(): select_item(2)
func _on_ItemButton4_pressed(): select_item(3)
func _on_ItemButton5_pressed(): select_item(4)
func _on_ItemButton6_pressed(): select_item(5)
func _on_ItemButton7_pressed(): select_item(6)
func _on_ItemButton8_pressed(): select_item(7)
func _on_ItemButton9_pressed(): select_item(8)
func _on_ItemButton10_pressed(): select_item(9)
func _on_ItemButton11_pressed(): select_item(10)
func _on_ItemButton12_pressed(): select_item(11)

func _on_PlayButton_pressed():
	$GUILayer/GUI.visible = false
	change_select_mode(true)
	var player := MultiplayerManager.add_player("creator", true, 0)
	var player_node := MultiplayerManager.spawn_player_node(player)
	var player_camera_node := add_player_screen_camera(player.id, player_node.get_path())
	player_node.position = map_node.FlagStart.position
	player_camera_node.current = true

func _on_GoToStartButton_pressed():
	change_select_mode(true)
	CreatorCamera.position = map_node.FlagStart.position
	CreatorCamera.position.x -= 256
	CreatorCamera.position.y -= 144
	if CreatorCamera.position.y > 0:
		CreatorCamera.position.y = 0

func _on_GoToEndButton_pressed():
	change_select_mode(true)
	CreatorCamera.position = map_node.FlagEnd.position
	CreatorCamera.position.x -= 256
	CreatorCamera.position.y -= 144
	if CreatorCamera.position.y > 0:
		CreatorCamera.position.y = 0

func _on_UndoButton_pressed():
	change_select_mode(true)
	print("Undo")

func _on_RedoButton_pressed():
	change_select_mode(true)
	print("Redo")

func _on_InfoButton_pressed():
	$GUILayer/GUI/InfoBubble.visible = !$GUILayer/GUI/InfoBubble.visible
	change_select_mode(true)

func _on_SettingsButton_pressed():
	change_select_mode(true)
	print("Open settings...")

