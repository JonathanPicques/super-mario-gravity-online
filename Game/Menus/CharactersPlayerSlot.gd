extends VBoxContainer

onready var Game = get_node("/root/Game")

onready var SlotJoinTexture = preload("res://Game/Menus/Textures/SlotJoin.png")
onready var SlotReadyTexture = preload("res://Game/Menus/Textures/SlotReady.png")
onready var SlotSearchTexture = preload("res://Game/Menus/Textures/SlotSearch.png")
onready var SlotSelectTexture = preload("res://Game/Menus/Textures/SlotSelect.png")
onready var InputDeviceTextures = [
	preload("res://Game/Menus/Textures/Keyboard.png"),
	preload("res://Game/Menus/Textures/Gamepad1.png"),
	preload("res://Game/Menus/Textures/Gamepad2.png"),
	preload("res://Game/Menus/Textures/Gamepad3.png"),
	preload("res://Game/Menus/Textures/Gamepad4.png"),
]

enum State { none, join, ready, search, select }

export var state = State.none
export var player_id := 0

func _ready():
	set_state(State.join)
	update_player()
	Game.GameMultiplayer.connect("player_add", self, "update_player")
	Game.GameMultiplayer.connect("player_remove", self, "update_player")
	Game.GameMultiplayer.connect("player_set_skin", self, "update_player")
	Game.GameMultiplayer.connect("player_set_ready", self, "update_player")

func set_state(new_state: int):
	state = new_state
	match state:
		State.join:
			$SlotState.texture = SlotJoinTexture
		State.ready:
			$SlotState.texture = SlotReadyTexture
		State.search:
			$SlotState.texture = SlotSearchTexture
		State.select:
			$SlotState.texture = SlotSelectTexture

func update_player(a = null, b = null, c = null):
	var player = Game.GameMultiplayer.get_player(player_id)
	if player != null:
		match player.ready:
			true: set_state(State.ready)
			false: set_state(State.select)
		$PlayerName.text = player.name
		$InputDevice.texture = InputDeviceTextures[player.input_device_id]
		$SlotState/CenterContainer/SkinTextureRect.texture = load(Game.skins[player.skin_id].preview_select_path if not player.ready else Game.skins[player.skin_id].preview_ready_path)
	else:
		if state != State.join:
			set_state(State.join)
		$PlayerName.text = ""
		$InputDevice.texture = null
		$SlotState/CenterContainer/SkinTextureRect.texture = null
