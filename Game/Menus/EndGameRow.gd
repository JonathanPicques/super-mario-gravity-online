extends HBoxContainer

#onready var Game = get_node("/root/Game")

func set_player_data(name: String, skin_id: int, position: int):
	$Name.text = name if name else "Unnamed"
	#$CenterContainer/Skin.texture = Game.get_skin_from_id(skin_id)
	$Position.text = "#" + str(position)
