extends Node

#This script needs to handle level timing and title displays
#setup level before the game starts
#get a callback when all pips have been completed and consider the level closed
#get a callback when the player dies and do a reset on the system

export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

export(NodePath) var ghost_node_path
onready var ghost_node = get_node(ghost_node_path)

export(NodePath) var pips_node_path
onready var pips_node = get_node(pips_node_path)

#Game handler screens========================================================
export(NodePath) var ready_screen_path
onready var ready_screen = get_node(ready_screen_path)

export(NodePath) var countdown_screen_path
onready var countdown_screen = get_node(countdown_screen_path)

export(NodePath) var levelcomplete_screen_path
onready var levelcomplete_screen = get_node(levelcomplete_screen_path)

#Stuff for displaying our main sections. This should probably be it's own handler and will need refactored
export(NodePath) var score_node_path
onready var score_node = get_node(score_node_path)

#A state hangler to keep track of what we're doing
var game_state = 0 #0: ready, 1: countdown, 2: playing, 3: level clear screen 4: game over screen

var powerup_time = 0
var current_powerup = ""	#lets make it so that there's only one powerup at once

var target_score = 100
var score = 0

var level_start_time = 0

# Score handling functions=======================================================
func add_score(by_this):
	score += by_this
	score_node.text = "Score: " + str(score)
	if (score > target_score):
		set_game_state(3)

# Stage present goal=============================================================
func _on_ReadyButton_pressed():
	#Ideally we'll play a resolve animation of some description
	ready_screen.visible = false
	#We need to hide our UI elements
	set_game_state(1)
	#Switch to countdown mode

func _on_NextLevelButton_pressed():
	target_score += 100
	score = 0
	set_game_state(0)	#Go back to our ready screen

func set_game_state(gamestate):
	#there'll be things we need to turn on/off
	game_state = gamestate
	#Handle visibility states
	ready_screen.visible = (game_state == 0)
	countdown_screen.visible = (game_state == 1)
	levelcomplete_screen.visible = (game_state == 3)
	#disable our actors
	player_node.visible = (game_state == 2)
	ghost_node.visible = (game_state == 2)
	
	if (game_state == 0): #setup and display our ready screen
		ready_screen.display_target(target_score)
	
	#handle trigger calls
	if (game_state == 1):
		countdown_screen.start_countdown()
		
	if (game_state == 2):
		do_level_setup();


# Main Game Functions ===========================================================

#The game needs to be split into play stages
#Level presentation: displays the goal score the player needs to get to
#Level primer which has the potential positions for the player and ghost and a 
#   few visual hints as to what could happen, as well as a countdown
#Actual level start
#Level complete screen which cycles back to the beginning

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#do_level_setup();
	set_game_state(0)
	pass # Replace with function body.

func do_level_setup():
	#Idea: break the screen up into sections and then use that logic for the placement of the character
	#This seems like a good idea, but it's not as it can start the player in situations where they cannot survive
	#var start_positions = [1, 2, 3, 4, 5, 6, 7]
	var startpos = floor(rand_range(1, 7))
	print (startpos)
	player_node.global_position = Vector2(startpos/7.0 * 1024, 300)
	
	#Based off of our start pos we can now look at positioning our enemy
	var direction = [-1, 1][randi() % 2]
	var dirstartpos = direction * floor(rand_range(3, 7))
	print (dirstartpos)
	var enemystartpos = startpos + dirstartpos
	
	enemystartpos = fposmod(enemystartpos, 8.0)	#Will need to make sure that this isn't zero
	#Ghost has to be not too close to the player, but we're simply prototyping at this stage
	#startpos = floor(rand_range(1, start_positions.size()))
	ghost_node.global_position =  Vector2(enemystartpos/7.0 * 1024, 300)
	ghost_node.reset_ghost()
	print(enemystartpos)
	#The last bit (of course) is picking the player start direction based off of where the enemy is and making sure we're not running into the ghost
	var enemydist = player_node.global_position.x - ghost_node.global_position.x
	
	var player_sign = sign (enemydist)
	if (enemydist > 512):
		player_sign = player_sign * -1
		
	player_node.set_moveDir(player_sign)
	
	pips_node.spawn_pickups(true, true, player_node.global_position.x)
	
	#pips_node.position.x = 0;	#reset this just in case it's moved
	
	level_start_time = Time.get_ticks_msec()
	pass

func pips_exhausted():
	#Have some clever stuff here that'll sort out what our rewards might be
	pips_node.spawn_pickups(true, true, player_node.global_position.x)

#Powerup callbacks
func do_powerup_eat_ghost():
	#for a limited time enable the "can eat ghost" effect
	#set the necessary flags
	#add in the ghost behaviour to make it run away
	ghost_node.bCanBeEaten = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#Step forward with our screen setup
		if (game_state != 2):
			var new_game_state = game_state + 1
			
			if (game_state == 3): #Handle our end of level stuff
				new_game_state = 0;
				target_score += 100
				score = 0
			
			set_game_state(new_game_state)
		
#	pass

#=========Powerup Stuff======================================================
func select_powerup(selected_powerup: String):
	print("powerup selected")
	#This needs to be broadcast through to:
	#Our player
	player_node.apply_powerup(selected_powerup);
	ghost_node.apply_powerup(selected_powerup);
	
	#The ghost
	#Some screen effefts thing
	#pass

