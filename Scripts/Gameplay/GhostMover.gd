extends MoverBase

var velocity = Vector2.ZERO
var speed = 220
var flee_speed = 250
var flee_position = 0
var slow_speed = 180

var screen_size
export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

var bCanBeEaten = false
var bGhostFlee = false
var bGhostRespawning = false

var respawn_pause = 3000

var function_time = 0

var sprite_side_buffer = 24

#===============Powerup Effectors========================
#values for this need to be global somehow so that they can be universally changed
var freeze_start = 0
var freeze_duration = 4000
var freeze_speed_factor = 0.5

var invisible_start = 0
var invisible_duration = 5000
var invislbe_dir_change_time = 0
var invisible_current_dir = 0

var repulse_action_end = 0
var repulse_action_duration = 1500
var repulse_distance_min = 100
var repulse_distance_max = 300
var repulse_max_force = 150 #So the player is 200, and the ghost 220, so I guess that this can't be too meaningful?

var tazer_action_end = 0
var tazer_action_duration = 750	#Very short action time
var tazer_distance = 250
var got_tazed_end = 0
var got_tazed_duration = 2000

func _ready():
	# Get the viewport size
	screen_size = get_viewport_rect().size
	# We need to know what our player is

func reset_ghost():
	bCanBeEaten = false;
	bGhostFlee = false;
	bGhostRespawning = false
	#Might need to reset any animation state here

func _physics_process(delta):
	if (!visible):
		return #disable this function
	# Basic character movement
	var input_vector = Vector2.ZERO
	input_vector.x = sign(player_node.global_position.x - position.x); # Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = 0; #Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	#=======Hande Powerup Check Functions
	if (OS.get_ticks_msec() < invisible_start + invisible_duration):
		#We need to affect our input_vector.x to give some sort of random movement
		if (OS.get_ticks_msec() > invislbe_dir_change_time):
			invislbe_dir_change_time = OS.get_ticks_msec() + rand_range(750, 1500)
			invisible_current_dir = rand_range(0, 4)
			invisible_current_dir = floor(invisible_current_dir) - 1
		input_vector.x = invisible_current_dir
		#PROBLEM: Need to have effects for looking confused
	
	if (OS.get_ticks_msec() < tazer_action_end):
		if (abs(player_node.global_position.x - position.x) < tazer_distance):
			got_tazed_end = OS.get_ticks_msec() + got_tazed_duration
			#PROBLEM: Need to play some effect for gettting tazed
	
		
	if (bCanBeEaten):	#We need to flee our player
		input_vector.x *= -1
	
	var move_speed = speed
	#Lazy state machine==================================================
	if (bCanBeEaten || OS.get_ticks_msec() < invisible_start + invisible_duration):
		move_speed = slow_speed
	
	#===Powerup affectors========================================
	if (OS.get_ticks_msec() < freeze_start + freeze_duration):
		move_speed *= freeze_speed_factor
	
	#========State for ghost eaten========================
	if (bGhostFlee):
		move_speed = flee_speed
		input_vector.x = sign(flee_position - position.x) #Change our target position
		#Need to check if we're within our position and then do a respawn action
		if (abs(flee_position - position.x) < 5):
			bGhostFlee = false
			bGhostRespawning = true
			function_time = Time.get_ticks_msec() + respawn_pause	#When will we finish respawning?
			print(function_time)
			
	if (bGhostRespawning):
		move_speed = 0 #Stay where we are for the respawn
		if (Time.get_ticks_msec() > function_time):
			bGhostRespawning = false
			bCanBeEaten = false
			
	
	velocity = input_vector.normalized() * move_speed
	#======Handle repuse Powerup=======================
	if (OS.get_ticks_msec() < repulse_action_end && abs(player_node.global_position.x - position.x) < repulse_distance_max):
		#Need to push the ghost back and away from the player, somehow...
		var repulseDistance = abs(player_node.global_position.x - position.x) - repulse_distance_min;
		repulseDistance = repulseDistance / (repulse_distance_max - repulse_distance_min);
		velocity += repulseDistance * input_vector.normalized() * repulse_max_force
	
	if (OS.get_ticks_msec() < got_tazed_end): #We've been tazed, so annul our movement
		velocity.x = 0
	
	move_and_slide(velocity)
	if (position.x < sprite_side_buffer):
		position.x = sprite_side_buffer
	if (position.x > screen_size.x - sprite_side_buffer):
		position.x = screen_size.x - sprite_side_buffer

func _on_Area2D_body_entered(body):
	#in theory this'll only be the player that we can contact with
	#notify the game system that we've touched the player
	#do the player die sequence
	if body.name == "PacMan":
		if bCanBeEaten && !bGhostFlee:
			print("Player ate the ghost!")
			bGhostFlee = true
			bCanBeEaten = false
			#Set our ghost flee position to the other quarter point on the screen from where we were caught as we'll logically be in a corner
			if (position.x < screen_size.x/2):
				flee_position = screen_size.x * 0.75
			else:
				flee_position = screen_size.x * 0.25
		else:
			print("Ghost killed the player!")
	pass # Replace with function body.

#=======Powerup stuff=============================
func apply_powerup(new_powerup:String):
	match new_powerup:
		"pup_freeze":
			#Apply freeze effect to ghost's stats
			print("Doing Ghost Freeze")
			freeze_start = OS.get_ticks_msec()
			#Need to play some sort of freeze effect or animation
		"pup_invisible":
			print("Doing player invisible")
			invisible_start = OS.get_ticks_msec()
			#Need to display a ? icon over the ghost to indicate that it's searching
		"pup_repulse":
			print("Doint repulse action")
			repulse_action_end = OS.get_ticks_msec() + repulse_action_duration
		"pup_tazer":
			print("Doing tazer action")
			tazer_action_end = OS.get_ticks_msec() + tazer_action_duration
