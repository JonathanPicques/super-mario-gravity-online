extends GameModeNode
class_name CreatorGameModeNode

enum State { moving, drawing, playing }

onready var History: HistoryNode = $History
onready var Quadtree: QuadtreeNode = $Quadtree
onready var HUDQuadtree: QuadtreeNode = $HUDQuadtree

onready var Drawers: Array = $GUILayer/GUI/Drawers.get_children()
onready var TopButtons: Array = $GUILayer/GUI/TopBar.get_children()
onready var DrawersBar: Sprite = $GUILayer/GUI/DrawersBar
onready var CreatorCamera: Camera2D = $GridContainer/Control1/ViewportContainer1/Viewport1/Camera2D

onready var Gui: Control = $GUILayer/GUI
onready var GuiModeLabel: Control = $GUILayer/GUI/ModeLabel

onready var Tilesets := {}

var state: int = State.drawing
var current_drawer_index := 0
var current_cell_position := Vector2(0, 0)

# @impure
func _ready():
	set_process(false)
	set_focus_neighbors()

# @impure
func _process(delta: float):
	match state:
		State.moving: 
			move_map()
			draw_map()
		State.drawing:
			draw_map()
	if Input.is_action_just_pressed("ui_cancel"):
		if $GUILayer/GUI/SettingsPopup.visible == true:
			$GUILayer/GUI/SettingsPopup.visible = false
			set_state(State.moving)
			return
		match state:
			State.moving: set_state(State.drawing)
			State.drawing: set_state(State.moving)
			State.playing: set_state(State.drawing)

# @async
# @impure
# @override
func init():
	# load map
	yield(MapManager.load_current_map(), "completed")

	# remove players
	var players := MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.inverted)
	for player in players:
		MultiplayerManager.remove_player(player.id)
	# remove popup
	remove_child(GamePopup)
	GamePopup.queue_free()
	GamePopup = null
	# load tilesets
	Tilesets["Wall"] = {"name": "Wall", "tile": 15, "icon": preload("res://Game/Creator/Textures/Icons/WallIcon.png"), "tilemap_node": Game.map_node.Wall}
	Tilesets["Water"] = {"name": "Water", "tile": 16, "icon": preload("res://Game/Creator/Textures/Icons/WaterIcon.png"), "tilemap_node": Game.map_node.Water}
	Tilesets["Oneway"] = {"name": "Oneway", "tile": 9, "icon": preload("res://Game/Creator/Textures/Icons/OnewayIcon.png"), "tilemap_node": Game.map_node.Oneway}
	Tilesets["Sticky"] = {"name": "Sticky", "tile": 8, "icon": preload("res://Game/Creator/Textures/Icons/StickyIcon.png"), "tilemap_node": Game.map_node.Sticky}
	# construct quadtree from existing doors
	for map_door_node in Game.map_node.DoorSlot.get_children():
		Quadtree.add_map_item(map_door_node, map_door_node.get_map_data().type)
	# construct quadtree from existing items
	for map_item_node in Game.map_node.ObjectSlot.get_children():
		Quadtree.add_map_item(map_item_node, map_item_node.get_map_data().type)
	# construct quadtree from existing tiles in tilemaps
	for tileset in Tilesets.values():
		var tiles = tileset.tilemap_node.get_used_cells()
		for tile in tiles:
			Quadtree.add_tile(tileset.tilemap_node.map_to_world(tile), tileset)
	# construct hud quadtree from drawers and top buttons
	HUDQuadtree.add_node(DrawersBar)
	for top_button in TopButtons:
		HUDQuadtree.add_node(top_button)

# @impure
# @override
func start():
	History.start()
	set_process(true)
	setup_split_screen()

# set_state changes the creator state between moving/drawing and playing.
# @impure
func set_state(new_state: int):
	# early exit
	if state == new_state:
		return
	# clear previous state
	match state:
		State.playing:
			Gui.visible = true
			CreatorCamera.current = true
			remove_player_screen_camera(0)
			MultiplayerManager.get_player_node(0).queue_free()
			MultiplayerManager.remove_player(0)
	# setup new state
	state = new_state
	match new_state:
		State.moving:
			for drawer in Drawers:
				drawer.release_focus()
			for top_button in TopButtons:
				top_button.release_focus()
			GuiModeLabel.text = "(ESC) move map"
		State.drawing:
			select_drawer(current_drawer_index)
			GuiModeLabel.text = "(ESC) select button"
		State.playing:
			Gui.visible = false
			var player := MultiplayerManager.add_player("creator", true, 0)
			var player_node := MultiplayerManager.spawn_player_node(player)
			yield(get_tree(), "idle_frame")
			var player_camera_node := add_player_screen_camera(player.id, player_node)
			player_node.position = Game.map_node.ObjectSlot.get_node("StartCage").Spawn1.global_position
			player_camera_node.current = true

# select_drawer selects the given drawer and focuses it.
# @impure
func select_drawer(drawer_index: int):
	set_state(State.drawing)
	Drawers[drawer_index].grab_focus()
	current_drawer_index = drawer_index

# set_focus_neighbors set the GUI buttons focus neighbors.
# @impure
func set_focus_neighbors():
	var drawer_i := 0
	var top_button_i := 0
	# set neighbors for top buttons
	for top_button_node in TopButtons:
		if top_button_i == 0:
			top_button_node.set("focus_neighbour_left", Drawers[Drawers.size() - 1].get_path())
			top_button_node.set("focus_neighbour_previous", Drawers[Drawers.size() - 1].get_path())
			top_button_node.set("focus_neighbour_right", TopButtons[top_button_i + 1].get_path())
			top_button_node.set("focus_neighbour_next", TopButtons[top_button_i + 1].get_path())
		elif top_button_i == TopButtons.size() - 1:
			top_button_node.set("focus_neighbour_left", TopButtons[top_button_i - 1].get_path())
			top_button_node.set("focus_neighbour_previous", TopButtons[top_button_i - 1].get_path())
			top_button_node.set("focus_neighbour_right", Drawers[0].get_path())
			top_button_node.set("focus_neighbour_next", Drawers[0].get_path())
		else:
			top_button_node.set("focus_neighbour_left", TopButtons[top_button_i - 1].get_path())
			top_button_node.set("focus_neighbour_previous", TopButtons[top_button_i - 1].get_path())
			top_button_node.set("focus_neighbour_right", TopButtons[top_button_i + 1].get_path())
			top_button_node.set("focus_neighbour_next", TopButtons[top_button_i + 1].get_path())
		top_button_node.set("focus_neighbour_top", top_button_node.get_path())
		top_button_node.set("focus_neighbour_bottom", Drawers[0].get_path())
		top_button_i += 1
	# set neighbors for drawers (bottom bar)
	for drawer_node in Drawers:
		if drawer_i == 0:
			drawer_node.set("focus_neighbour_left", TopButtons[TopButtons.size() - 1].get_path())
			drawer_node.set("focus_neighbour_previous", TopButtons[TopButtons.size() - 1].get_path())
			drawer_node.set("focus_neighbour_right", Drawers[drawer_i + 1].get_path())
			drawer_node.set("focus_neighbour_next", Drawers[drawer_i + 1].get_path())
		elif drawer_i == Drawers.size() - 1:
			drawer_node.set("focus_neighbour_left", Drawers[drawer_i - 1].get_path())
			drawer_node.set("focus_neighbour_previous", Drawers[drawer_i - 1].get_path())
			drawer_node.set("focus_neighbour_right", TopButtons[0].get_path())
			drawer_node.set("focus_neighbour_next", TopButtons[0].get_path())
		else:
			drawer_node.set("focus_neighbour_left", Drawers[drawer_i - 1].get_path())
			drawer_node.set("focus_neighbour_previous", Drawers[drawer_i - 1].get_path())
			drawer_node.set("focus_neighbour_right", Drawers[drawer_i + 1].get_path())
			drawer_node.set("focus_neighbour_next", Drawers[drawer_i + 1].get_path())
		drawer_node.set("focus_neighbour_top", TopButtons[0].get_path())
		drawer_node.set("focus_neighbour_bottom", drawer_node.get_path())
		drawer_i += 1
	
	TopButtons[0].grab_focus()

# move_map moves the camera with up/down/left/right.
# @impure
var current_frame = 0
func move_map():
	current_frame += 1
	if current_frame % 2 == 0: # slow down the moving
		return
	if Input.is_action_pressed("ui_left"):
		CreatorCamera.translate(Vector2(-MapManager.cell_size, 0))
	if Input.is_action_pressed("ui_right"):
		CreatorCamera.translate(Vector2(MapManager.cell_size, 0))
	if Input.is_action_pressed("ui_up"):
		CreatorCamera.translate(Vector2(0, -MapManager.cell_size))
	if Input.is_action_pressed("ui_down") and CreatorCamera.position.y < 32: # toolbar size
		CreatorCamera.translate(Vector2(0, MapManager.cell_size))

# draw_map draws cells on the mouse.
# @impure
func draw_map():
	# compute mouse position
	var mouse_pos := get_viewport().get_mouse_position()
	# early return if the mouse is over the HUD
	if HUDQuadtree.get_item(Rect2(mouse_pos, Vector2(MapManager.cell_size, MapManager.cell_size))):
		return
	# compute cell position (aligned to cell_size grid)
	var cell_position := Vector2(MapManager.snap_value(mouse_pos.x + CreatorCamera.position.x), MapManager.snap_value(mouse_pos.y + CreatorCamera.position.y))
	
	# If mouse right is just pressed: rollback placeholder(s)
	if Input.is_action_just_pressed("ui_click_bis"):
		History.rollback()
		History.start()
	# If mouse left is just released: commit placeholder(s)
	if Input.is_action_just_released("ui_click"):
		History.commit()
		History.start()
	# If mouse right is just released: commit cleared cell(s)
	if Input.is_action_just_released("ui_click_bis"):
		History.commit()
		History.start()
	
	# remove cells if mouse right is pressed
	if Input.is_action_pressed("ui_click_bis"):
		var drawer_index := 0
		for drawer in Drawers:
			if not Drawers[drawer_index].is_cell_free(cell_position):
				History.push_step(Drawers[drawer_index].action(Drawers[drawer_index].ActionType.clear, cell_position, drawer_index))
			drawer_index += 1
	
	if cell_position != current_cell_position or Input.is_action_just_released("ui_click_bis"):
		if not Input.is_action_pressed("ui_click_bis"):
			# if cell changed and mouse left was not pressed, destroy the previous placeholder
			if not Input.is_action_pressed("ui_click"):
				History.rollback()
				History.start()
			# if the cell is free, fill it with the drawer as a placeholder
			if is_cell_free(cell_position) and Drawers[current_drawer_index].can_draw_cell(cell_position):
				History.push_step(Drawers[current_drawer_index].action(Drawers[current_drawer_index].ActionType.fill, cell_position, current_drawer_index))
	
	# save the currently drawn cell position
	current_cell_position = cell_position

# is_cell_free returns true if the cell is free at the given position.
# @pure
func is_cell_free(pos: Vector2) -> bool:
	# TODO: water is not in quadtree, nor decors
	return Quadtree.get_item(Rect2(pos, Vector2(MapManager.cell_size, MapManager.cell_size))) == null

func update_preview():
	 # Wait for game to actually start
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var img = get_viewport().get_texture()
	img.get_data().save_png('res://Maps/' + MapManager.current_map.get_basename() + '.png')

# @signal
func _on_PlayButton_pressed():
	History.rollback()
	History.start()
	set_state(State.playing)
	update_preview()	

# @signal
func _on_UndoButton_pressed():
	set_state(State.drawing)
	History.rollback()
	if History.can_undo():
		History.undo()
	History.start()

# @signal
func _on_RedoButton_pressed():
	set_state(State.drawing)
	History.rollback()
	if History.can_redo():
		History.redo()
	History.start()

# @signal
func _on_GoToStartButton_pressed():
	History.rollback()
	History.start()
	set_state(State.drawing)
	CreatorCamera.position = Game.map_node.ObjectSlot.get_node("StartCage").Spawn1.global_position
	CreatorCamera.position.x -= 256
	CreatorCamera.position.y -= 144
	if CreatorCamera.position.y > 0:
		CreatorCamera.position.y = 0

# @signal
func _on_GoToEndButton_pressed():
	History.rollback()
	History.start()
	set_state(State.drawing)
	CreatorCamera.position = Game.map_node.ObjectSlot.get_node("FlagEnd").position
	CreatorCamera.position.x -= 256
	CreatorCamera.position.y -= 144
	if CreatorCamera.position.y > 0:
		CreatorCamera.position.y = 0

func _on_SettingsButton_pressed():
	$GUILayer/GUI/SettingsPopup.visible = true
	$GUILayer/GUI/SettingsPopup/CloseButton.grab_focus()

func _on_CloseButton_pressed():
	$GUILayer/GUI/SettingsPopup.visible = false
	set_state(State.moving)

# @signal
func _on_HomeButton_pressed():
	Game.goto_home_menu_scene()
	
func _on_SaveButton_pressed():
	Game.map_node.save_map($GUILayer/GUI/SettingsPopup/NameInput.text, $GUILayer/GUI/SettingsPopup/DescriptionInput.text, "garden")
	$GUILayer/GUI/SettingsPopup.visible = false
	$GUILayer/GUI/TopBar/SettingsButton.grab_focus()

func _on_OpenButton_pressed():
	Game.goto_select_map_scene("Creator")

func _on_DeleteButton_pressed():
	print("Delete map: TODO, confirm popup")

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


func _on_InfoButton_pressed():
	print("Show infos")
