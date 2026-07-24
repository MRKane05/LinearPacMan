extends Node

export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)

export(NodePath) var fill_box_path
onready var fill_box = get_node(fill_box_path)

export(NodePath) var score_label_path
onready var score_label = get_node(score_label_path)

export(NodePath) var powerup_icon_path
onready var powerup_icon = get_node(powerup_icon_path)

export(Array, Resource) var PowerupItemList = []

#This will be different per box
export(float) var max_score = 5000

export(bool) var uses_score = true

var current_fill = 0.0

func _ready():
	randomize() 
	#do_score_add(500)
	pass # Replace with function body.

func do_score_add(thisScore: int):
	#Ideally this should have an animation, and a callback, but we're going to not care for the moment
	var tween = get_tree().create_tween()
	score_label.text = "+" + str(thisScore)
	$AnimationPlayer.play("get_boost")
	#score_label.rect_scale = Vector2(0.125, 0.125)
	#tween.tween_property(score_label, "scale", Vector2(1.0,  1.0), 0.5)
	if (uses_score):
		current_fill += thisScore
	else:
		current_fill += 1
		score_label.text = "+1"
	
	var fill_ammount = 100.0*current_fill/max_score
	if (current_fill > max_score):
		reward_starting_powerup();
		fill_ammount = 100
		current_fill = 0 #reset this
		#Play some extra animation or something
		reward_starting_powerup()
	
	
	if (fill_ammount > fill_box.value):	#So that we don't go from full back to partially filled again
		tween.tween_property(fill_box, "value", fill_ammount, 1.0)
	else:
		fill_box.value = 0
		tween.tween_property(fill_box, "value", fill_ammount, 1.0)

var anim_powerup_item

func powerup_animation_callback():
	#level_controller.add_start_powerup(powerup_item)
	var powerupAdded = level_controller.pips_node.powerup_items.addPowerup(anim_powerup_item, powerup_icon.global_position)
	#powerup_items.addPowerup(pickup_item.pickup_resource, pickup_item.global_position)
	if (!powerupAdded):
		level_controller.add_start_powerup(anim_powerup_item)

func reward_starting_powerup():
	# We need to know what rewards are unlocked
	# and have a system by and which this can be passed through
	# Then this needs to be passed onto somewhere
	var powerup_int = int(rand_range(1.0, PowerupItemList.size()))
	var powerup_item = PowerupItemList[powerup_int]
	
	powerup_icon.texture = powerup_item.powerup_icon
	powerup_icon.visible = true
	$AnimationPlayer.play("get_powerup")
	anim_powerup_item = powerup_item #PROBLEM: Potential bug introduced here with powerup rewards
	#Need to have a little function here that'll handle the powerup assignment
	


