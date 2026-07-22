extends Node2D

export var return_var = -1 #This is hard-coded to return something when the player presses action

export(NodePath) var points_earned_path
onready var points_earned# = get_node(points_earned_path)

export(NodePath) var time_remaining_path
onready var time_remaining #= get_node(time_remaining_path)

export(NodePath) var total_score_path
onready var total_score #= get_node(total_score_path)

export(Array, NodePath) var PrizeBoxes = []

func display_target(target):
	#target_text.text = "Target: " + str(target);
	pass

var level_score = 0
var score_time_remaining = 0
var score_total = 0
var time_score_scale = 10

func _ready():
	call_deferred("_resolve_nodes")

func _resolve_nodes():
	points_earned  = get_node_or_null(points_earned_path)
	time_remaining = get_node_or_null(time_remaining_path)
	total_score    = get_node_or_null(total_score_path)

func display_level_complete(new_level_score: int, new_time_remaining: float, new_total_score: int):
	level_score = new_level_score
	score_time_remaining = new_time_remaining
	score_total = new_total_score
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
		1 :
			time_remaining.text = str(score_time_remaining) + "s"
		2 :
			time_remaining.text = str(score_time_remaining * time_score_scale)
		3:
			total_score.text = str(score_total)
	

func update_prize_boxes(additive_score: int):
	for i in PrizeBoxes.size():
		var powerup_box = get_node(PrizeBoxes[i]);
		if (powerup_box.visible):
			powerup_box.do_score_add(additive_score)


func handle_inputaction(gamestate: int):
	if (return_var == -1):
		return gamestate + 1 #base behaviour is to increment this by one
	return return_var

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
