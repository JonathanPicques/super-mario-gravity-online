extends TextureButton

var textures := []
var current_index = 0

func _ready():
	var map_infos = MapManager.get_maps_infos()
	print(map_infos.size())
	for i in range(0, min(map_infos.size() - 1, 10)):
		textures.append(load("res://Maps/" + map_infos[i]["filename"].get_basename() + ".png"))
	if $Label.text != "":
		$Preview.texture = textures[0]

func _on_Timer_timeout():
	if $Label.text != "Random":
		return
	$Preview.texture = textures[current_index]
	current_index += 1
	if current_index == textures.size():
		current_index = 0
