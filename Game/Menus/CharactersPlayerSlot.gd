extends VBoxContainer

onready var Game = get_node("/root/Game")

const SlotJoinTexture := preload("res://Game/Menus/Textures/SlotJoin.png")
const SlotReadyTexture := preload("res://Game/Menus/Textures/SlotReady.png")
const SlotSearchTexture := preload("res://Game/Menus/Textures/SlotSearch.png")
const SlotSelectTexture := preload("res://Game/Menus/Textures/SlotSelect.png")
const InputDeviceTextures := [
	preload("res://Game/Menus/Textures/Keyboard.png"),
	preload("res://Game/Menus/Textures/Gamepad1.png"),
	preload("res://Game/Menus/Textures/Gamepad2.png"),
	preload("res://Game/Menus/Textures/Gamepad3.png"),
	preload("res://Game/Menus/Textures/Gamepad4.png"),
]

enum State { none, join, ready, search, select }

export var state = State.none
export var player_id := 0

# @impure
# @driven(lifecycle)
func _ready():
	set_state(State.join)
	on_update_player()
	Game.GameMultiplayer.connect("player_add", self, "on_update_player")
	Game.GameMultiplayer.connect("player_remove", self, "on_update_player")
	Game.GameMultiplayer.connect("player_set_skin", self, "on_update_player")
	Game.GameMultiplayer.connect("player_set_ready", self, "on_update_player")

# @impure
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

# on_update_player is called to update the character slot on player add/remove/skin change/ready change.
# @driven(signal)
# @impure
func on_update_player(a = null, b = null, c = null):
	# wait one frame to ensure player is null if it was removed this frame
	yield(get_tree(), "idle_frame")
	var player = Game.GameMultiplayer.get_player(player_id)
	if player != null:
		# player added or changed skin/ready
		match player.ready:
			true: set_state(State.ready)
			false: set_state(State.select)
		$PlayerName.text = player.name
		$InputDevice.texture = InputDeviceTextures[player.input_device_id]
		$SlotState/CenterContainer/SkinTextureRect.texture = Game.get_skin_from_id(player.skin_id, player.ready)
	else:
		# player removed
		if state != State.join:
			set_state(State.join)
		$PlayerName.text = ""
		$InputDevice.texture = null
		$SlotState/CenterContainer/SkinTextureRect.texture = null
