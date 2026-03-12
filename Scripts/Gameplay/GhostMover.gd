extends KinematicBody2D

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
	
	if (bCanBeEaten):	#We need to flee our player
		input_vector.x *= -1
	
	var move_speed = speed
	#Lazy state machine==================================================
	if (bCanBeEaten):
		move_speed = slow_speed
		
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
