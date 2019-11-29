extends Control

onready var Game = get_node("/root/Game")
onready var RoomInput = $MarginContainer/VBoxContainer/RoomCodeInput

func _ready():
	RoomInput.grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Game.goto_home_menu_scene()
	if Input.is_action_just_pressed("ui_accept"):
		print("Send code ", RoomInput.text)
