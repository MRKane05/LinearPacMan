extends Node

# Store file paths instead of preloaded streams
export(Array, String, FILE, "*.mp3") var playlist_paths = []

onready var track1 = $Track1
onready var track2 = $Track2

export var fade_duration = 1.0

var current_track_player : AudioStreamPlayer2D
var next_track_player : AudioStreamPlayer2D
var tween : Tween

var _shuffled_paths = []
var _current_index = 0

func _ready():
	randomize()
	tween = Tween.new()
	add_child(tween)
	
	current_track_player = track1
	next_track_player = track2
	
	track1.connect("finished", self, "_on_song_finished")
	track2.connect("finished", self, "_on_song_finished")
	
	_build_shuffled_playlist()

func play_music():
	if playlist_paths.empty():
		push_warning("MusicManager: no songs in playlist!")
		return
	_play_current()

func _play_current():
	if _shuffled_paths.empty():
		_build_shuffled_playlist()
	
	var path = _shuffled_paths[_current_index]
	
	# Load just the next track
	var stream = load(path)
	if stream == null:
		push_error("MusicManager: failed to load " + path)
		return
	
	_crossfade_to(stream)

func _on_song_finished():
	if not current_track_player.playing:
		# Free the old track's stream now we're done with it
		next_track_player.stream = null
		
		_current_index += 1
		if _current_index >= _shuffled_paths.size():
			_current_index = 0
			_build_shuffled_playlist()
		_play_current()

func _crossfade_to(audio_stream: AudioStream):
	if current_track_player.stream == audio_stream and current_track_player.playing:
		return
	
	tween.stop_all()
	tween.remove_all()
	
	next_track_player.stream = audio_stream
	next_track_player.volume_db = -80
	next_track_player.play()
	
	tween.interpolate_property(current_track_player, "volume_db", 0, -80, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.interpolate_property(next_track_player, "volume_db", -80, 0, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.connect("tween_all_completed", self, "_on_crossfade_completed")
	tween.start()
	
	var temp = current_track_player
	current_track_player = next_track_player
	next_track_player = temp

func _on_crossfade_completed():
	# Safe to free the old stream now the crossfade is done
	if tween.is_connected("tween_all_completed", self, "_on_crossfade_completed"):
		tween.disconnect("tween_all_completed", self, "_on_crossfade_completed")
	next_track_player.stream = null  # next_track_player is now the old faded-out one

func _build_shuffled_playlist():
	var last_path = null
	if not _shuffled_paths.empty():
		last_path = _shuffled_paths.back()
	
	_shuffled_paths = playlist_paths.duplicate()
	
	for i in range(_shuffled_paths.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = _shuffled_paths[i]
		_shuffled_paths[i] = _shuffled_paths[j]
		_shuffled_paths[j] = temp
	
	if last_path != null && _shuffled_paths[0] == last_path && _shuffled_paths.size() > 1:
		var temp = _shuffled_paths[0]
		_shuffled_paths[0] = _shuffled_paths[1]
		_shuffled_paths[1] = temp

func stop_music():
	tween.stop_all()
	tween.remove_all()
	tween.interpolate_property(current_track_player, "volume_db", 0, -80, fade_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func pause_music(paused: bool):
	track1.stream_paused = paused
	track2.stream_paused = paused
