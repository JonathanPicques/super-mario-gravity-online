extends "res://Game/Modes/GameMode.gd"

onready var PositionLabel: Label = $CanvasLayerUI/PositionLabel
onready var StageClearSFX: AudioStream = preload("res://Game/Modes/Race/Sounds/smb_stage_clear.ogg")

# _ready is called to load the race map.
# @driven(lifecycle)
# @impure
func _ready():
	map_scene = load(options.map).instance()
	MapSlot.add_child(map_scene)
	# load end/start position
	var end_pos = map_scene.find_node("FlagEnd").position
	var start_pos = map_scene.find_node("FlagStart").position
	# load peers
	var peers = Game.get_all_peers()
	for peer_id in peers:
		var peer = peers[peer_id]
		var player_scene = load(Game.Players[peer.player_id].scene_path).instance()
		player_scene.set_name(str(peer.id))
		player_scene.set_position(start_pos)
		player_scene.set_network_master(peer.id)
		MapSlot.add_child(player_scene)
	# goal position
	goal_position = end_pos

# _process updates the self peer position in HUD.
# @driven(lifecycle)
# @impure
func _process(delta):
	if Game.self_peer.player_ranking != -1:
		PositionLabel.text = str(Game.self_peer.player_ranking + 1)