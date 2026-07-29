extends Node2D

export var return_var = -1 #This is hard-coded to return something when the player presses action

export(NodePath) var points_earned_path
onready var points_earned# = get_node(points_earned_path)

export(NodePath) var time_remaining_path
onready var time_remaining #= get_node(time_remaining_path)

export(NodePath) var total_score_path
onready var total_score #= get_node(total_score_path)

export(NodePath) var high_score_path
onready var high_score_node #= get_node(total_score_path)

export(NodePath) var high_score_title_path
onready var high_score_title_node #= get_node(total_score_path)

export(Array, NodePath) var PrizeBoxes = []

onready var sound_player

onready var animation_timer = $AnimationTimer

const SOUNDS = {
	"collect"   : preload("res://Sounds/GameEffects/freesounds123-collect-item-retro-sfx-383230.wav"),
	"final"	: preload("res://Sounds/GameEffects/CashMachinePing.mp3"),
	"highscore" : preload("res://Sounds/GameEffects/floraphonic-tada-military-1-183974.mp3"),
	"ping" : preload("res://Sounds/GameEffects/koiroylers-cheerful-ping-356011.mp3")
}

func display_target(target):
	#target_text.text = "Target: " + str(target);
	pass

var level_score = 0
var score_time_remaining = 0
var time_score = 0
var high_score = 0
var aggregate_score = 0
var time_score_scale = 12
var bHighScoreSet = false
var bSkipDisplay = false

var score_index = 0

#This little function is being copy and pasted everywhere...
func play_sound(stream):
	if (sound_player == null):
		sound_player =  $AudioStreamPlayer2D
	sound_player.stream = stream
	sound_player.play()

func _ready():
	call_deferred("_resolve_nodes")

func _resolve_nodes():
	points_earned  = get_node_or_null(points_earned_path)
	time_remaining = get_node_or_null(time_remaining_path)
	total_score    = get_node_or_null(total_score_path)
	high_score_node = get_node_or_null(high_score_path)
	high_score_title_node = get_node_or_null(high_score_title_path)

#Need a bypass function to allow this screen to be quickly dismissed

var timer_wait = 0.5

func display_level_complete(new_level_score: int, new_time_remaining: float, new_time_score: float, new_aggregate_score: int, new_high_score: int, bIsNewHighscore: bool):
	#Global.set_can_accept_input(false)
	bSkipDisplay = false
	
	level_score = new_level_score
	score_time_remaining = new_time_remaining
	time_score = new_time_score
	aggregate_score = new_aggregate_score
	high_score = new_high_score
	bHighScoreSet = bIsNewHighscore
	#this function needs to show our different elements that we've go score wise
	#it needs to go in order, with sounds, and with flashy animations
	#it needs to be able to skip and still have everything handled correctly
	points_earned.text = ""
	time_remaining.text = ""
	total_score.text = ""
	if (!visible): #Just in case we've been deactivated this pass for a message
		return
	
	score_index = 0
	animation_timer.wait_time = timer_wait
	animation_timer.one_shot = true
	animation_timer.start()
	for i in range(0, 3):
		if (get_node(PrizeBoxes[i]).visible):
			get_node(PrizeBoxes[i]).reset()
	display_score_structure(score_index) #Display this to kick everything off

func display_score_structure(entry: int):
	#This needs to display the correct score set, and make a sound
	match(entry):
		0 :
			points_earned.text = str(level_score)
			if (!bSkipDisplay):
				play_sound(SOUNDS["collect"])
		1 :
			time_remaining.text = str("%0.2f" % score_time_remaining, "s")
			if (!bSkipDisplay):
				play_sound(SOUNDS["collect"])
		2 :
			time_remaining.text = str(int(time_score))
			if (!bSkipDisplay):
				play_sound(SOUNDS["collect"])
		3:
			total_score.text = str(aggregate_score)
			if (!bSkipDisplay):
				play_sound(SOUNDS["final"])
		4: #Highscore set
			if (!bHighScoreSet):
				play_sound(SOUNDS["final"])
				high_score_title_node.text = "HIGHSCORE"
				high_score_node.text = str(high_score)
			else:
				play_sound(SOUNDS["highscore"])
				high_score_title_node.text = "NEW HIGHSCORE"
				high_score_node.text = str(high_score) + "!"
	
	if (entry >= 5):
		#update_prize_boxes(level_score + time_score)
		#Play some sound for this, or maybe have something that does one at a time? I dunno
		#Global.set_can_accept_input(true)
		if (get_node(PrizeBoxes[entry-5]).visible):
			get_node(PrizeBoxes[entry-5]).do_score_add(level_score + time_score, !bSkipDisplay)
	
	if (entry >= 6):
		bSkipDisplay = true #So that we'll fast release when the user presses action

func handle_inputaction(gamestate: int):
	if (!bSkipDisplay): 
		bSkipDisplay = true
		animation_timer.stop()
		_on_AnimationTimer_timeout()
		return null #So that we'll send back a pass that won't have any input command
	else:
		if (return_var == -1):
			return gamestate + 1 #base behaviour is to increment this by one
		return return_var

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationTimer_timeout():
	score_index = score_index + 1
	if (score_index < 7 && !bSkipDisplay):
		animation_timer.wait_time = timer_wait
		animation_timer.one_shot = true
		animation_timer.start()
		display_score_structure(score_index)
	if (bSkipDisplay):
		for value in range(score_index, 7):
			display_score_structure(value)
	pass # Replace with function body.
