extends Node

#This script needs to handle level timing and title displays
#setup level before the game starts
#get a callback when all pips have been completed and consider the level closed
#get a callback when the player dies and do a reset on the system

export(Array, NodePath) var UI_Menus = []

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

export(NodePath) var die_screen_path
onready var die_screen = get_node(die_screen_path)

export(NodePath) var dialogue_node_path
onready var dialogue_node = get_node(dialogue_node_path)

#Screens for our ingame prompts=======================================
export(NodePath) var ingame_dialogue_handler_path
onready var ingame_dialogue_handler = get_node(ingame_dialogue_handler_path)

#Stuff for displaying our main sections. This should probably be it's own handler and will need refactored
export(NodePath) var score_node_path
onready var score_node = get_node(score_node_path)



#A state hangler to keep track of what we're doing
#var game_state = 0 #0: ready, 1: countdown, 2: playing, 3: level clear screen 4: game over screen 5: display message screen

var powerup_time = 0
var current_powerup = ""	#lets make it so that there's only one powerup at once

var target_score = 100
var score = 0

var level_start_time = 0

var ingame_dialogue_active = false

# Score handling functions=======================================================
func add_score(by_this):
	score += by_this
	score_node.text = "Score: " + str(score)
	if (score > target_score):
		set_game_state(3)

# Stage present goal=============================================================
func _on_ReadyButton_pressed():
	#Ideally we'll play a resolve animation of some description
	#ready_screen.visible = false
	#We need to hide our UI elements
	set_game_state(1)
	#Switch to countdown mode

func _on_NextLevelButton_pressed():
	target_score += 100
	score = 0
	set_game_state(0)	#Go back to our ready screen

func set_game_state(gamestate):
	Global.game_state = gamestate
	#POBLEM: Handle menu visibility states (this is going to break as this expands I think)
	for i in range(UI_Menus.size()):
		if (UI_Menus[i]):
			get_node(UI_Menus[i]).visible = (gamestate == i)
	
	
	#disable our actors
	player_node.visible = (Global.game_state == 2)
	player_node.reset_character()
	ghost_node.visible = (Global.game_state == 2)
	
	#Specific per-case screen things
	if (Global.game_state == 0): #setup and display our ready screen
		ready_screen.display_target(target_score)
	
	
	#handle trigger calls
	if (Global.game_state == 1):
		countdown_screen.start_countdown()
	
	if (Global.game_state == 2):
		do_level_setup()
	
	#if (Global.game_state == 5):
		#We need to set our conversation screen displaying text
		#get_node(UI_Menus[5]).do_display_dilogue()
	
	#This is where we need to keep an eye out to see if we've got to display
	#a message (or similar)
	#Otherwise tally up our games played since the last event
	#die_screen.visible = (Global.game_state == 4)
	if (Global.game_state == 4):
		var games_played = int(SaveManager.get_value("total_games"))
		var story_games = int(SaveManager.get_value("story_games"))
		games_played = games_played + 1
		story_games = story_games + 1
		
		SaveManager.set_value("total_games", games_played)
		SaveManager.set_value("story_games", story_games)
		var story_index = SaveManager.get_value("story_index")
		var line = StoryManager.get_dialogue(story_index) 
		if (line.trigger == "deaths"):
			if (story_games >= line.triggernum):
				print("Got Story Trigger!")
				get_node(UI_Menus[5]).do_display_dilogue()
				#Global.game_state = 5	#This is our conversation screen window
				#In theory I suppose we could just re-call this function...
				set_game_state(5)
		
		#set_game_state(0)
		#Change music to menu music
		#display stats on the die screen
		pass


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
	
	#Grab some details from our story manager to see if we should be doing an unlock
	var story_index = SaveManager.get_value("story_index")
	var line = StoryManager.get_dialogue(story_index)
	var necessary_pickup = -1
	
	if (line != null && line != {} && line.size() != 0):
		if (line.trigger == "powerup"):
			necessary_pickup = line.powerup_reveal
			#Make sure we update our save manager so that this'll be unlocked from this point forward
			SaveManager.set_value("powerup_unlock", max(int(SaveManager.get_value("powerup_unlock")), necessary_pickup))
		
	var pickup_spawned = pips_node.spawn_pickups(true, true, player_node.global_position.x, necessary_pickup)
	
	
	#pips_node.position.x = 0;	#reset this just in case it's moved
	
	level_start_time = Time.get_ticks_msec()
	
	#This needs to get populated after everything has been revealed
	if (pickup_spawned && necessary_pickup !=-1):
		#Need to bring up the dialogue screen and pause
		#set_game_state(6) #This enables our ingame dialogue in our state machine
		create_callback_timer(0.75, "display_ingame_dialogue")

func display_ingame_dialogue():
	ingame_dialogue_active = true
	ingame_dialogue_handler.visible = true
	ingame_dialogue_handler.display_dialogue_powerup() #This'll need some arguments
	get_tree().paused = true #Not totally sure how we'll unpause given the current setup...


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
		if (Global.game_state != 2):
			var new_game_state = Global.game_state # + 1
			if (UI_Menus[new_game_state]):
				if (get_node(UI_Menus[new_game_state]).has_method("handle_inputaction")):
					new_game_state = get_node(UI_Menus[new_game_state]).handle_inputaction(new_game_state)
				
			if (Global.game_state == 3): #Handle our end of level stuff
				new_game_state = 0;
				target_score += 100
				score = 0
			
			if (Global.game_state == 4):
				target_score = 100
				score = 0
				new_game_state = 0;
			
			set_game_state(new_game_state)
		

func return_from_paused():
	#In theory our paused menu (ingame dialogue or settings) will hide itself, so we only need to do sundry stuff
	pass

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

func display_die_screen():
	set_game_state(4)
	pass

func ghost_ate_player():
	#Our player has died
	create_callback_timer(2, "display_die_screen")
	#Wait a set amount of time for the animation to finish
	#Bring up our hint/discussion screen
	#Bring up the game over screen
	pass


#This one is in seconds, just to be extra-confusing
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
