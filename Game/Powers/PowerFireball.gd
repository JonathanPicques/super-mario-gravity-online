extends PowerNode
class_name PowerFireballNode

const FireballExplosionScene := preload("res://Game/Effects/Particles/FireballBasicExplosion.tscn")
const FireballFollowExplosionScene := preload("res://Game/Effects/Particles/FireballFollowExplosion.tscn")
const FireballGhostExplosionScene := preload("res://Game/Effects/Particles/FireballGhostExplosion.tscn")

enum FireballType { basic, follow, follow_ghost }
const SPEED := 300.0

onready var FireballTimer: Timer = $Timer
onready var FireballSprite: AnimatedSprite = $AnimatedSprite
onready var FireballExplosionPoint: Node2D = $ExplosionPoint
onready var FireballLaunchPoint: Node2D = $LaunchPoint

export(FireballType) var type = FireballType.basic

var this: KinematicBody2D = self as Object
var target_player_node: Node2D

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
	position = player_node.PlayerPowerPoint.global_position + FireballLaunchPoint.position
	get_parent().remove_child(self)
	Game.map_node.ObjectSlot.add_child(self)
	# find best target (previous player for following fireball, or 1st player for ghost following fireball)
	if MultiplayerManager.players.size() > 1:
		var target_player
		match type:
			FireballType.follow: target_player = MultiplayerManager.get_closest_player(player_node.player.id)
			FireballType.follow_ghost: target_player = MultiplayerManager.get_players(MultiplayerManager.SortPlayerMethods.ranked)[0]
		if target_player and target_player.id != player_node.player.id:
			target_player_node = MultiplayerManager.get_player_node(target_player.id)

	# Check if there is a scarecrow to use as default target
	if target_player_node == null and type != FireballType.basic:
		var scarecrow_node = Game.map_node.get_node("Scarecrow")
		if scarecrow_node != null:
			target_player_node = scarecrow_node.Target
		
	#play_launch()

# @impure
# @override
func process_power(delta: float):
	# update the hud
	set_hud_progress(FireballTimer.time_left / FireballTimer.wait_time)
	# move the fireball towards its target (or straight if no target)
	var velocity := ((target_player_node.global_position - position).normalized() * SPEED * delta) if is_instance_valid(target_player_node) else Vector2(SPEED * delta * cos(rotation), SPEED * delta * sin(rotation))
	var collision := this.move_and_collide(velocity)
	rotation = velocity.angle()
	if collision:
		if collision.collider is PlayerNode:
			collision.collider.apply_death(global_position)
			if collision.collider == target_player_node:
				play_explosion()
				return true
		if collision.collider.get_parent().get_parent() is ScarecrowNode:
			var scarecrow_node = collision.collider.get_parent().get_parent()
			scarecrow_node.apply_death(global_position)
#		if type != FireballType.follow_ghost: # if we hit something, destroy the fireball
		# TODO: if not first player or not ghost
		play_explosion()
		return true
	if FireballTimer.is_stopped():
		play_explosion()
		return true
	return false

# @impure
# @override
func finish_power():
	# TODO: reattach to player to clear warning (revert detach from player) from Player process_powers
	FireballTimer.stop()

#func play_launch():
#	var node := FireballLaunchcene.instance()
#	node.position = FireballLaunchPoint.global_position
#	node.rotation = PI if player_node.direction == -1 else 0.0
#	Game.map_node.ParticleSlot.add_child(node)

# @impure
func play_explosion():
	var fireball_explosion_node = null
	match type:
		FireballType.basic: fireball_explosion_node = FireballExplosionScene.instance()
		FireballType.follow: fireball_explosion_node = FireballFollowExplosionScene.instance()
		FireballType.follow_ghost: fireball_explosion_node = FireballGhostExplosionScene.instance()
	if fireball_explosion_node != null:
		fireball_explosion_node.position = FireballExplosionPoint.global_position
		Game.map_node.ParticleSlot.add_child(fireball_explosion_node)
