extends KinematicBody2D
class_name MoverBase

export(NodePath) var char_sprite_path
onready var char_sprite = get_node(char_sprite_path)

#Get our animation players
export (NodePath) var _animation_player
onready var animation_player:AnimationPlayer = get_node(_animation_player)

#onready var audio_players = [$AudioPlayer1, $AudioPlayer2, $AudioPlayer3]
var current_player = 0

#What powerups are affecting us?
export(Array, Resource) var AffectedPowerups = []

var boost_type = 0
var moveDir = 1

#===============Animation Handlers=======================
func set_animation(anim_name: String):
	if animation_player:
		if animation_player.has_animation(anim_name):
			animation_player.current_animation = anim_name	#Dunno if we can do this?
		else:
			pass
	else:
		pass

#===============Powerup Effectors========================
#values for this need to be global somehow so that they can be universally changed
var freeze_start = 0
var freeze_speed_factor = 0.5

var invisible_start = 0
var invislbe_dir_change_time = 0
var invisible_current_dir = 0

var repulse_action_end = 0
var repulse_distance_min = 200
var repulse_distance_max = 400
var repulse_max_force = 200 #So the player is 200, and the ghost 220, so I guess that this can't be too meaningful?

var taser_action_end = 0
var taser_distance = 250
var got_tazed_end = 0

#States fpr active powerups================================
var bFreezeActive = false
var bRepulseActive = false
var btaserActive = false
var bInvisibleActive = false

#Handle our audio source playing
func play_sound(stream):
	var player = AudioStreamPlayer2D.new()
	add_child(player)
	player.stream = stream
	player.play()
	yield(player, "finished")
	player.queue_free()

#This could do with being part of a base class
func set_boostzone(new_boost_type):
	#boost types: 0, none, 1 left, 2, right, 3 both
	boost_type = new_boost_type
	pass

func set_moveDir(new_moveDir: float):
	if (new_moveDir == 0):	#Quick catch for stationary objects
		new_moveDir = 1
	moveDir = new_moveDir
	char_sprite.scale.x = moveDir * 0.25 #PROBLEM: This is terrible coding for handling temp sprites

func clear_powerups():
	pass
	
	#=======Powerup stuff=============================
func apply_powerup(new_powerup:String):
	match new_powerup:
		"pup_freeze":
			#Apply freeze effect to ghost's stats
			#print("Doing Ghost Freeze")
			freeze_start = OS.get_ticks_msec()
			bFreezeActive = true
			create_callback_timer(Global.freeze_duration, "freeze_callback")
			#Need to play some sort of freeze effect or animation
		"pup_invisible":
			#print("Doing player invisible")
			invisible_start = OS.get_ticks_msec()
			bInvisibleActive = true
			#Need to display a ? icon over the ghost to indicate that it's searching
			create_callback_timer(Global.invisible_duration, "invisible_callback")
		"pup_repulse":
			#print("Doint repulse action")
			repulse_action_end = OS.get_ticks_msec() + Global.repulse_action_duration
			bRepulseActive = true
			create_callback_timer(Global.repulse_action_duration, "repulse_callback")
		"pup_taser":
			#print("Doing taser action")
			taser_action_end = OS.get_ticks_msec() + Global.taser_action_duration
			btaserActive = true
			create_callback_timer(Global.taser_action_duration, "taser_callback")

func freeze_callback():
	bFreezeActive = false
	print ("freeze duration finished")

func repulse_callback():
	bRepulseActive = false
	print("repulse duration finished")

func taser_callback():
	btaserActive = false
	print("taser duration finished")
	
func invisible_callback():
	bInvisibleActive = false
	print("invisible duration finished")

func reset_character():
	pass

func create_callback_timer(duration: float, callback: String):
	var timer = get_node_or_null(callback)
	if timer == null:
		timer = Timer.new()
		timer.name = callback
		add_child(timer)  # Only add if newly created
		timer.connect("timeout", self, callback)  # Only connect once
	
	timer.wait_time = duration
	timer.one_shot = true
	timer.start()
