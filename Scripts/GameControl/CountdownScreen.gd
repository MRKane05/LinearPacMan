extends Node

export(NodePath) var levelcontrol_node_path
onready var levelcontrol_node = get_node(levelcontrol_node_path)

export(NodePath) var target_score_path
onready var target_score = get_node(target_score_path)

export(NodePath) var round_node_path
onready var round_node = get_node(round_node_path)

onready var sound_player = $AudioStreamPlayer2D

var finish_time = 0
var countdown_time = 3000
var bCountdownActive = false

const SOUNDS = {
	"beep"   : preload("res://Sounds/GameEffects/Start_Beep.wav"),
	"tone"	: preload("res://Sounds/GameEffects/Start_Tone.wav")
}

# Called when the node enters the scene tree for the first time.
func start_countdown(level: int, target: int):
	bCountdownActive = true
	round_node.text = "Level: " + str(level + 1)	#Because our game starts at 0 but that doesn't reat well
	target_score.text = "Target: " + str(target)
	finish_time = Time.get_ticks_msec() + countdown_time
	$AnimationPlayer.stop()
	$AnimationPlayer.play("LevelOpening")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (bCountdownActive):
		var num_time = str(ceil((finish_time-Time.get_ticks_msec())/1000.0))
		$CountDownClock/CountDownInt.text = num_time
		#Now do our countdown circular graphic
		var num_frac = fposmod((finish_time-Time.get_ticks_msec())/1000.0, 1.0)
		$CountDownClock/TextureProgress.value = num_frac * 100
		
		if (Time.get_ticks_msec() > finish_time):
			levelcontrol_node.set_game_state(2)	
			bCountdownActive = false#Set our game actually playing

func play_beep():
	play_sound(SOUNDS["beep"])

func play_tone():
	play_sound(SOUNDS["tone"])

#Handle our audio source playing
func play_sound(stream):
	sound_player.stream = stream
	sound_player.play()
