extends GameModeNode
class_name CreatorGameModeNode

onready var Drawers: Array = $GUILayer/GUI/Drawers.get_children()
onready var TopButtons :=  $GUILayer/GUI/TopBar.get_children()
onready var CreatorCamera: Camera2D = $GridContainer/Control1/ViewportContainer1/Viewport1/Camera2D
onready var CurrentItemSlot := $CurrentItemSlot

onready var Quadtree: QuadtreeNode = $Quadtree
onready var HUDQuadtree: QuadtreeNode = $HUDQuadtree

onready var History: HistoryNode = $History

var tilesets := {}
var drawer_index := 0
var is_select_mode := true
var is_playing := false
var previous_cell_position := Vector2(-1, -1)

var transactions := []
var is_placeholder_updated := false

func _ready():
	set_process(false)

# @impure
func init():
	# load map
	yield(load_map(""), "completed")
	# remove popup
	$Popup.queue_free()
	remove_child($Popup)
	# load tilesets (with hard coded)
	tilesets = {
		"Wall": {"tilemap": map_node.Map, "tile": 15, "icon": preload("res://Game/Creator/Textures/Icons/WallIcon.png")},
		"Sticky": {"tilemap": map_node.Sticky, "tile": 8, "icon": preload("res://Game/Creator/Textures/Icons/StickyIcon.png")},
		"Oneway": {"tilemap": map_node.Map, "tile": 9, "icon": preload("res://Game/Creator/Textures/Icons/OnewayIcon.png")},
		"Water": {"tilemap": map_node.Water, "tile": 16, "icon": preload("res://Game/Creator/Textures/Icons/WaterIcon.png")}
	}

# @impure
func start():
	set_process(true)
	setup_split_screen()
	Drawers[0].grab_focus()
	# construct quadtree from existing items
	Quadtree.add_items(map_node.ObjectSlot.get_children())
	# construct hud quadtree
	for btn in TopButtons:
		HUDQuadtree.add_item(btn)
	HUDQuadtree.add_item($GUILayer/GUI/ElementsBar) # FIXME not working
	# set keyboard/gamepad gui navigation
	set_focus_neighbours()

# @impure
func _process(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		if is_playing == false:
			change_select_mode(!is_select_mode)
		else:
			$GUILayer/GUI.visible = true
			remove_player_screen_camera(0)
			MultiplayerManager.get_player_node(0).queue_free()
			MultiplayerManager.remove_player(0)
			is_playing = false
	if is_playing:
		return
	
	var mouse_position := get_viewport().get_mouse_position() + CreatorCamera.position
	var new_cell_position := Vector2(
		MapManager.snap_value(mouse_position.x),
		MapManager.snap_value(mouse_position.y)
	)
	
	if new_cell_position != previous_cell_position:
		previous_cell_position = new_cell_position
		update_item_placeholder(mouse_position)
	
	if Input.is_action_just_pressed("ui_click") and HUDQuadtree.get_item(mouse_position) == null:
		History.start()
	
	if is_placeholder_updated and Input.is_action_pressed("ui_click") and HUDQuadtree.get_item(mouse_position) == null:
		if is_cell_free(new_cell_position):
			History.push_step({"type": "fill_cell", "pos": new_cell_position, "drawer_index": drawer_index}, {"type": "clear_cell", "pos": new_cell_position, "drawer_index": drawer_index})
			is_placeholder_updated = false

	if Input.is_action_just_released("ui_click") and HUDQuadtree.get_item(mouse_position) == null:
		History.commit()

	if Input.is_action_just_pressed("ui_click_bis") and HUDQuadtree.get_item(mouse_position) == null:
		History.start()
	
	if is_placeholder_updated and Input.is_action_pressed("ui_click_bis") and HUDQuadtree.get_item(mouse_position) == null:
		clear_cell(new_cell_position)
		is_placeholder_updated = false

	if Input.is_action_just_released("ui_click_bis") and HUDQuadtree.get_item(mouse_position) == null:
		History.commit()

	if !is_select_mode:
		if Input.is_action_pressed("ui_left"):
			CreatorCamera.translate(Vector2(-MapManager.ceil_size, 0))
		if Input.is_action_pressed("ui_right"):
			CreatorCamera.translate(Vector2(MapManager.ceil_size, 0))
		if Input.is_action_pressed("ui_up"):
			CreatorCamera.translate(Vector2(0, -MapManager.ceil_size))
		if Input.is_action_pressed("ui_down") and CreatorCamera.position.y < 32: # toolbar size
			CreatorCamera.translate(Vector2(0, MapManager.ceil_size))

# @impure
func update_item_placeholder(mouse_position: Vector2):
	var position = mouse_position - CreatorCamera.position
	is_placeholder_updated = true
	#var placeholder = Drawers[drawer_index].placeholder
	#var pivot: Vector2 = Drawers[drawer_index].get_item_pivot()
	#placeholder.position.x = MapManager.snap_value(position[0]) + pivot.x
	#placeholder.position.y = MapManager.snap_value(position[1]) + pivot.y
	#placeholder.visible = HUDQuadtree.get_item(position) == null and Quadtree.get_item(position) == null

# @impure
func set_focus_neighbours():
	var i := 0
	for drawer_node in Drawers:
		if i == 0:
			drawer_node.set("focus_neighbour_left", TopButtons[TopButtons.size() - 1].get_path())
			drawer_node.set("focus_neighbour_previous", TopButtons[TopButtons.size() - 1].get_path())
			drawer_node.set("focus_neighbour_right", Drawers[i + 1].get_path())
			drawer_node.set("focus_neighbour_next", Drawers[i + 1].get_path())
		elif i == Drawers.size() - 1:
			drawer_node.set("focus_neighbour_left", Drawers[i - 1].get_path())
			drawer_node.set("focus_neighbour_previous", Drawers[i - 1].get_path())
			drawer_node.set("focus_neighbour_right", TopButtons[0].get_path())
			drawer_node.set("focus_neighbour_next", TopButtons[0].get_path())
		else:
			drawer_node.set("focus_neighbour_left", Drawers[i - 1].get_path())
			drawer_node.set("focus_neighbour_previous", Drawers[i - 1].get_path())
			drawer_node.set("focus_neighbour_right", Drawers[i + 1].get_path())
			drawer_node.set("focus_neighbour_next", Drawers[i + 1].get_path())
		drawer_node.set("focus_neighbour_top", TopButtons[0].get_path())
		drawer_node.set("focus_neighbour_bottom", drawer_node.get_path())
		i += 1
	i = 0
	for top_button_node in TopButtons:
		if i == 0:
			top_button_node.set("focus_neighbour_left", Drawers[Drawers.size() - 1].get_path())
			top_button_node.set("focus_neighbour_previous", Drawers[Drawers.size() - 1].get_path())
			top_button_node.set("focus_neighbour_right", TopButtons[i + 1].get_path())
			top_button_node.set("focus_neighbour_next", TopButtons[i + 1].get_path())
		elif i == TopButtons.size() - 1:
			top_button_node.set("focus_neighbour_left", TopButtons[i - 1].get_path())
			top_button_node.set("focus_neighbour_previous", TopButtons[i - 1].get_path())
			top_button_node.set("focus_neighbour_right", Drawers[0].get_path())
			top_button_node.set("focus_neighbour_next", Drawers[0].get_path())
		else:
			top_button_node.set("focus_neighbour_left", TopButtons[i - 1].get_path())
			top_button_node.set("focus_neighbour_previous", TopButtons[i - 1].get_path())
			top_button_node.set("focus_neighbour_right", TopButtons[i + 1].get_path())
			top_button_node.set("focus_neighbour_next", TopButtons[i + 1].get_path())
		top_button_node.set("focus_neighbour_top", top_button_node.get_path())
		top_button_node.set("focus_neighbour_bottom", Drawers[0].get_path())
		i += 1

func change_select_mode(mode: bool):
	if mode == is_select_mode:
		return
	is_select_mode = mode
	$GUILayer/GUI/ModeLabel.text = "(ESC) select items" if !is_select_mode else "(ESC) move map"
	if !is_select_mode:
		for btn in Drawers:
			btn.release_focus()
		for btn in TopButtons:
			btn.release_focus()
	else:
		Drawers[drawer_index].grab_focus()

func is_cell_free(pos: Vector2):
	for drawer in Drawers:
		if not drawer.is_cell_free(pos):
			return false
	return true

func clear_cell(pos: Vector2):
	for i in range(0, Drawers.size()):
		if not Drawers[i].is_cell_free(pos):
			History.push_step({"type": "clear_cell", "pos": pos, "drawer_index": i}, {"type": "fill_cell", "pos": pos, "drawer_index": i})

func select_drawer(index: int):
	change_select_mode(true)
	drawer_index = index

func _on_ItemButton_pressed(): select_drawer(0)
func _on_ItemButton2_pressed(): select_drawer(1)
func _on_ItemButton3_pressed(): select_drawer(2)
func _on_ItemButton4_pressed(): select_drawer(3)
func _on_ItemButton5_pressed(): select_drawer(4)
func _on_ItemButton6_pressed(): select_drawer(5)
func _on_ItemButton7_pressed(): select_drawer(6)
func _on_ItemButton8_pressed(): select_drawer(7)
func _on_ItemButton9_pressed(): select_drawer(8)
func _on_ItemButton10_pressed(): select_drawer(9)
func _on_ItemButton11_pressed(): select_drawer(10)
func _on_ItemButton12_pressed(): select_drawer(11)

func _on_PlayButton_pressed():
	$GUILayer/GUI.visible = false
	var player := MultiplayerManager.add_player("creator", true, 0)
	var player_node := MultiplayerManager.spawn_player_node(player)
	yield(get_tree(), "idle_frame")
	var player_camera_node := add_player_screen_camera(player.id, player_node)
	player_node.position = map_node.FlagStart.position
	player_camera_node.current = true
	is_playing = true

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

func _on_UndoButton_button_down():
	change_select_mode(true)
	if History.can_undo():
		History.undo()

func _on_RedoButton_button_down():
	change_select_mode(true)
	if History.can_redo():
		History.redo()

func _on_InfoButton_pressed():
	$GUILayer/GUI/InfoBubble.visible = !$GUILayer/GUI/InfoBubble.visible
	change_select_mode(true)

func _on_SettingsButton_pressed():
	$GUILayer/GUI/SettingsPopup.visible = true
	$GUILayer/GUI/SettingsPopup/CloseButton.grab_focus()

func _on_CloseButton_button_up():
	$GUILayer/GUI/SettingsPopup.visible = false

func _on_SaveButton_button_up():
	print('save')

func _on_HomeButton_button_up():
	Game.goto_home_menu_scene()
