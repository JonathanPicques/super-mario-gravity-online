extends Node
class_name AudioManagerNode

onready var CrossFadeTween: Tween = $CrossFadeTween
onready var MusicStreamPlayer1: AudioStreamPlayer = $MusicStreamPlayer1
onready var MusicStreamPlayer2: AudioStreamPlayer = $MusicStreamPlayer2

var sound_volume := 0.0
var no_sound_volume := -100.0
var cross_fade_duration := 0.4
var last_music_stream_path: String

# @impure
func _ready():
	MusicStreamPlayer1.volume_db = no_sound_volume
	MusicStreamPlayer2.volume_db = no_sound_volume

# play_music plays a music and crossfades a previous music playing.
# @impure
func play_music(music_stream_path: String):
	if music_stream_path == last_music_stream_path:
		return
	var music_stream: AudioStream = load(music_stream_path)
	last_music_stream_path = music_stream_path
	if MusicStreamPlayer1.playing:
		MusicStreamPlayer2.stream = music_stream
		CrossFadeTween.remove_all()
		CrossFadeTween.interpolate_property(MusicStreamPlayer1, "volume_db", null, no_sound_volume, cross_fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		CrossFadeTween.interpolate_property(MusicStreamPlayer2, "volume_db", sound_volume, sound_volume, cross_fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		CrossFadeTween.start()
		MusicStreamPlayer2.play()
		MusicStreamPlayer2.seek(0.0)
		yield(CrossFadeTween, "tween_all_completed")
		MusicStreamPlayer1.stop()
	elif MusicStreamPlayer2.playing:
		MusicStreamPlayer1.stream = music_stream
		CrossFadeTween.remove_all()
		CrossFadeTween.interpolate_property(MusicStreamPlayer1, "volume_db", sound_volume, sound_volume, cross_fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		CrossFadeTween.interpolate_property(MusicStreamPlayer2, "volume_db", null, no_sound_volume, cross_fade_duration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		CrossFadeTween.start()
		MusicStreamPlayer1.play()
		MusicStreamPlayer1.seek(0.0)
		yield(CrossFadeTween, "tween_all_completed")
		MusicStreamPlayer2.stop()
	else:
		MusicStreamPlayer1.stream = music_stream
		CrossFadeTween.remove_all()
		CrossFadeTween.interpolate_property(MusicStreamPlayer1, "volume_db", no_sound_volume, sound_volume, cross_fade_duration / 10.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		CrossFadeTween.start()
		MusicStreamPlayer1.play()
		MusicStreamPlayer1.seek(0.0)
