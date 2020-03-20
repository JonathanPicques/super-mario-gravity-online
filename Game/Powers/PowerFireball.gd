extends PowerNode
class_name PowerFireballNode

enum FireballType { normal, follow, follow_ghost }
const SPEED := 120.0

onready var FireballTimer: Timer = $Timer
onready var FireballSprite: Sprite = $Sprite

export(FireballType) var type = FireballType.follow_ghost

var this: KinematicBody2D = self as Object
var target_player_node: PlayerNode

# @impure
func _ready():
	this.position = Vector2(-100000, -100000) # TODO: clean this
	this.add_collision_exception_with(player_node)
	if type == FireballType.follow_ghost:
		this.set_collision_mask_bit(Game.PHYSICS_LAYER_SOLID, false)

# @impure
# @override
func start_power():
	# start timer
	FireballTimer.start()
	# detach from player
	rotation = PI if player_node.direction == -1 else 0.0
	position = player_node.PlayerSprite.get_node("PowerSpawn").global_position
	get_parent().remove_child(self)
	Game.map_node.ObjectSlot.add_child(self)
	# find best target (previous player for following fireball, or 1st player for ghost following fireball)
	var target_player: Dictionary
	
	if MultiplayerManager.players.size() > 1:
		match type:
			FireballType.follow: target_player = MultiplayerManager.get_closest_player(player_node.player.id)
			FireballType.follow_ghost: target_player = MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0]
		if target_player and target_player.id != player_node.player.id:
			target_player_node = MultiplayerManager.get_player_node(target_player.id)

# @impure
# @override
func process_power(delta: float):
	# update the hud
	set_hud_progress(FireballTimer.time_left / FireballTimer.wait_time)
	# move the fireball towards its target (or straight if no target)
	var velocity := ((target_player_node.position - position).normalized() * SPEED * delta) if is_instance_valid(target_player_node) else Vector2(SPEED * delta * cos(rotation), SPEED * delta * sin(rotation))
	var collision := this.move_and_collide(velocity)
	rotation = velocity.angle()
	if collision:
		if collision.collider is PlayerNode:
			collision.collider.apply_death(global_position)
			if collision.collider == target_player_node:
				# TODO: explosion FX
				return true
		if type != FireballType.follow_ghost: # if we hit something, destroy the fireball
			# TODO: explosion FX
			return true
	# TODO: fizzle FX
	return FireballTimer.is_stopped()

# @impure
# @override
func finish_power():
	# TODO: reattach to player to clear warning (revert detach from player) from Player process_powers
	FireballTimer.stop()
