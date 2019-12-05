extends Sprite

# @impure
func trail_sprite(player_sprite: Sprite):
	scale = player_sprite.global_scale
	offset = player_sprite.offset
	texture = player_sprite.texture
	hframes = player_sprite.hframes
	vframes = player_sprite.vframes
	material = player_sprite.material
	rotation = player_sprite.global_rotation
	position = player_sprite.global_position
	centered = player_sprite.centered
	# set the frame in last
	frame = player_sprite.frame
