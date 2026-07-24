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


func display_level_complete(new_level_score: int, new_time_remaining: float, new_time_score: float, new_aggregate_score: int, new_high_score: int, bIsNewHighscore: bool):
	Global.set_can_accept_input(false)
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
	$AnimationPlayer.stop() #This is needed because it'll be called through more than once
	$AnimationPlayer.play("DoScoreDisplay")

func display_score_structure(entry: int):
	#This needs to display the correct score set, and make a sound
	match(entry):
		0 :
			points_earned.text = str(level_score)
			play_sound(SOUNDS["collect"])
		1 :
			time_remaining.text = str("%0.2f" % score_time_remaining, "s")
			play_sound(SOUNDS["collect"])
		2 :
			time_remaining.text = str(int(time_score))
			play_sound(SOUNDS["collect"])
		3:
			total_score.text = str(aggregate_score)
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
		
		#Really our prize boxes need to be updated as part of this process
		5:
			update_prize_boxes(level_score + time_score)
			#Play some sound for this, or maybe have something that does one at a time? I dunno
			Global.set_can_accept_input(true)

func update_prize_boxes(additive_score: int):
	for i in PrizeBoxes.size():
		var powerup_box = get_node(PrizeBoxes[i]);
		if (powerup_box.visible):
			yield(get_tree().create_timer(0.5), "timeout") #PROBLEM: Added a hard yeild just to get timing right for this, player be damned
			powerup_box.do_score_add(additive_score)
			play_sound(SOUNDS["ping"])


func handle_inputaction(gamestate: int):
	if (return_var == -1):
		return gamestate + 1 #base behaviour is to increment this by one
	return return_var

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
