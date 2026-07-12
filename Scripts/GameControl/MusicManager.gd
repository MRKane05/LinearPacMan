extends Node

# References to our AudioStreamPlayers
onready var track1 = $Track1
onready var track2 = $Track2

# Crossfade duration in seconds
export var fade_duration = 1.0

# Keep track of which track is currently active
var current_track_player : AudioStreamPlayer2D
var next_track_player : AudioStreamPlayer2D

var tween : Tween

func _ready():
	# Create and add a Tween node for smooth fading
	tween = Tween.new()
	add_child(tween)
	
	current_track_player = track1
	next_track_player = track2

func play_music(audio_stream : AudioStream):
	# If the same song is already playing, do nothing
	if current_track_player.stream == audio_stream and current_track_player.playing:
		return
		
	# Assign the new stream to the inactive player and start it silently
	next_track_player.stream = audio_stream
	next_track_player.volume_db = -80 # -80dB effectively mutes it
	next_track_player.play()
	
	# Fade out the old track and fade in the new one
	tween.interpolate_property(current_track_player, "volume_db", 0, -80, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(next_track_player, "volume_db", -80, 0, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	# Swap the pointers
	var temp = current_track_player
	current_track_player = next_track_player
	next_track_player = temp

func stop_music():
	tween.interpolate_property(current_track_player, "volume_db", 0, -80, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
