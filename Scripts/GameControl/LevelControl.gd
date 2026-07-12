extends Node

class LineSection:
	var start: int = 0
	var end: int = 100
	var offset: Vector2 = Vector2(0,0)

#This script needs to handle level timing and title displays
#setup level before the game starts
#get a callback when all pips have been completed and consider the level closed
#get a callback when the player dies and do a reset on the system

onready var game_timer = $GameLevelTimer

export(Array, NodePath) var UI_Menus = []

#export(NodePath) var level_pickuphandler_path
#onready var level_pickuphandler_ = get_node(level_pickuphandler_path)

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
export(NodePath) var high_score_node_path
onready var high_score_node = get_node(high_score_node_path)

export(NodePath) var current_score_node_path
onready var current_score_node = get_node(current_score_node_path)

export(NodePath) var score_node_path
onready var score_node = get_node(score_node_path)

export(NodePath) var target_score_node_path
onready var target_score_node = get_node(target_score_node_path)

export(NodePath) var game_time_display_path
onready var game_time_display = get_node(game_time_display_path)


#Portal system
export(NodePath) var portal_system_path
onready var portal_system = get_node(portal_system_path)

#Bits and pieces for our support quote screen
export(NodePath) var support_quote_path
onready var support_quote = get_node(support_quote_path)

#Prompt to press X to change direction======================================
export(NodePath) var x_prompt_path
onready var x_prompt = get_node(x_prompt_path)

#Screen overlay effects because everything is in one gigantic class========
export(NodePath) var effect_freeze_path
onready var effect_freeze = get_node(effect_freeze_path)

#for the moment lets setup our sections manually
#export(Array, LineSection) var line_sections = []
var line_sections = [] #x,y is the offset, and z is the bracket. Step up the brackets to find the offset

#A state hangler to keep track of what we're doing
#var game_state = 0 #0: ready, 1: countdown, 2: playing, 3: level clear screen 4: game over screen 5: display message screen

var powerup_time = 0
var current_powerup = ""	#lets make it so that there's only one powerup at once

var current_round = 0
var target_score = 200
var score = 0
var aggregate_score = 0

var level_start_time = 0

var ingame_dialogue_active = false

var max_score = 0

#End Dialogue features================================
var bHighscoreSet = false
var bAllowInput = true
var debounce = 0.8	#A button debounce for screens that end gameplay screens to cover accidental presses

var level_is_fragment = 0

export(Array, Resource) var start_powerups = []

var rng = RandomNumberGenerator.new()

func add_start_powerup(thisPowerup: Resource):
	if (!start_powerups.has(thisPowerup)):
		start_powerups.append(thisPowerup)

# Score handling functions=======================================================
func add_score(by_this):
	score += by_this
	score_node.text = str(score)
	
	aggregate_score += by_this
	current_score_node.text = str(aggregate_score)
	
	if (score >= target_score):
		set_game_state(3)
		#We've got a level complete, so should also increment our level counter and check against our json
		var level_count = int(SaveManager.get_value("level_count"))
		level_count = level_count + 1
		SaveManager.set_value("level_count", level_count)
		
		var story_index = SaveManager.get_value("story_index")
		if (story_index < StoryManager.get_node_number()): #So we don't run out the end of our story lines
			var line = StoryManager.get_dialogue(story_index) 
			if (line != null && line != {} && line.size() != 0):
				if (line.trigger == "deaths" && line.leveltriggers > 0):
					if (level_count >= line.leveltriggers):
						level_count = 0 #Reset this
						SaveManager.set_value("level_count", level_count)
						#Display a dialogue for the player to read. Somehow
						get_node(UI_Menus[5]).do_display_dilogue()
						dialogue_node.return_var = 3
						#debounce
						bAllowInput = false
						create_callback_timer(debounce, "enable_control_input")
						set_game_state(5)
						pass
	
	if (aggregate_score > max_score):
		max_score = aggregate_score
		high_score_node.text = str(max_score)
		bHighscoreSet = true

# Stage present goal=============================================================
func _on_ReadyButton_pressed():
	#Ideally we'll play a resolve animation of some description
	#ready_screen.visible = false
	#We need to hide our UI elements
	set_game_state(1)
	#Switch to countdown mode

func _on_NextLevelButton_pressed():
	current_round += 1
	target_score = 200 + current_round * 70
	target_score_node.text = str(target_score)
	score = 0
	set_game_state(0)	#Go back to our ready screen

func enable_control_input():
	bAllowInput = true

func set_game_state(gamestate):
	#Quickly tidy up any left over effectors
	effect_freeze.visible = false
	
	
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
		if (current_round == 0):
			bHighscoreSet = false
			aggregate_score = 0	#Reset our aggregate score as this is a game start thing (this might need another stage)
	
	
	#handle trigger calls
	if (Global.game_state == 1):
		#At this stage we need to know if we're going to do a fragment
		#so that we can play a little reveal animation also
		if (randf() > 0.75): #1:20 odds of a fragment happening
			level_is_fragment = rng.randi_range(1, 2)
		else:
			level_is_fragment = 0
		set_fragments()
		countdown_screen.start_countdown(current_round, target_score)
	
	if (Global.game_state == 2):
		do_level_setup()
	
	#Do stuff if player has died
	if (Global.game_state == 4 || Global.game_state == 3 || Global.game_state == 5):
		var saved_max_score = SaveManager.get_value("max_score")
		if (max_score > saved_max_score):
			#PROBLEM: Need to note that we've set a highscore and the feedback should reflect that!
			SaveManager.set_value("max_score", max_score)
	
	#Do the level complete stuff
	if (Global.game_state == 3):
		levelcomplete_screen.update_prize_boxes(target_score)
		#PROBLEM: Need a debounce on this screen just in case the player was trying to change direction
		bAllowInput = false
		create_callback_timer(debounce, "enable_control_input")
	
	#This is where we need to keep an eye out to see if we've got to display
	#a message (or similar)
	#Otherwise tally up our games played since the last event
	#die_screen.visible = (Global.game_state == 4)
	if (Global.game_state == 4):
		select_support_statement()
		var games_played = int(SaveManager.get_value("total_games"))
		var story_games = int(SaveManager.get_value("story_games"))
		games_played = games_played + 1
		story_games = story_games + 1
		current_round = 0 #Clear our current round because we died
		
		SaveManager.set_value("total_games", games_played)
		SaveManager.set_value("story_games", story_games)
		var story_index = SaveManager.get_value("story_index")
		if (story_index < StoryManager.get_node_number()): #So we don't run out the end of our story lines
			var line = StoryManager.get_dialogue(story_index) 
			if (line != null && line != {} && line.size() != 0):
				if (line.trigger == "deaths"):
					if (story_games >= line.triggernum):
						print("Got Story Trigger!")
						get_node(UI_Menus[5]).do_display_dilogue()
						#Global.game_state = 5	#This is our conversation screen window
						#In theory I suppose we could just re-call this function...
						bAllowInput = false
						create_callback_timer(debounce, "enable_control_input")
						dialogue_node.return_var = 4
						set_game_state(5)
		
		#set_game_state(0)
		#Change music to menu music
		#display stats on the die screen
		pass

var high_score_support = ["You set a new high score! That's fantastic! Keep trying to see how high you can get!",
"A new high score! There's no stopping you now!", "Don't skip this screen too quickly, because you set a new high score!",
"Any time you get a new high score it's worth phoning home about!"]

var close_to_high_score = ["So close to a new highscore! Just do that again, except with more points!", 
"That must have been frustrating to come so close to a highscore, breathe, collect yourself, try again!", 
"Nearly a highschore! I hope you're not planning on making a habit of this!",
"You were robbed! That run should have ended with a new highscore!"]

var lower_quartile = ["You were only just getting warmed up!", "Don't let that run get you down, you need to prepare for a good one!",
"Whoops! Lets just keep going and forget that run", "Perhaps you need a little more sleep before trying again"]

var half_quartile = ["Over half way to a new highscore, practice makes perfect!", 
"I call that a ditto-run, it's what gets the work done without being pompus",
"Get back into the swing of it!", "Go on! The next run is going to be a winner!"]

var top_quartile = ["You were really rolling with that run!", "You were raking in the points during that run!",
"Deep breath, compose yoursef, because that run was awesome!", "Gets quick when you're at higher levels!", "You were robbed! That run was going so well!"]

var hidden_message = ["AGIªUHŠH˜H© ©HIGHM¥SCORE%Gð¦N†OæK¥HÐ Ðîh", " 33'!'  3  !	 ›Æ³Æ¾ÆÉÆÔÆÞÆêÆóÆýÆÇ æCHARACTER ;  NICKNAMEÿ!H:PAKMANÿ",
"©ÿ…©KEEPÂ¥ŠðG .ÉÆŠðLPÂTRYINGí--------ÿ-/24Ç ÿÇÿ¢", "ÀLM©ST…¥)Ð¥PÅQð…QæÌæÌLDÔü™9Ø… ±ä¥ÉÿÐ©Ð¥ÉÿÐ¥•¹` ",
"00 38 e5 05 c9 20 b0 31 a5 4b 85 05 a9 05 85 06 c6 06 d0 04 a9 02 d0 1c e6 05 a5 05 29 03 a8 b1"]

func get_random_item(arr: Array):
	if arr.empty():
		return null # Return null or handle the empty array safety check
		
	var random_index = randi() % arr.size()
	return arr[random_index]

#This could really be a class within itself...
func select_support_statement():
	var pac_image = int(SaveManager.get_value("pac_reveal"))
	var display_name = "PAC"
	if (pac_image == 0):
		display_name = "??"	
		
	die_screen.set_speaker_icon_name(pac_image, display_name)
	
	if (pac_image == 0):	#Set our quote after having set our speaker details. Don't know why I did it this way
		support_quote.text = get_random_item(hidden_message)
		return
	
	if (bHighscoreSet):
		support_quote.text = get_random_item(high_score_support)
		return
	
	#At this point we need to do an evaluation of the score as to what we're going to say
	if (aggregate_score > max_score - 70): #Just short of a new highscore
		support_quote.text = get_random_item(close_to_high_score)
		return;
	elif (aggregate_score < max_score * 0.25):
		support_quote.text = get_random_item(lower_quartile)
		return;
	elif (aggregate_score < max_score * 0.5):
		support_quote.text = get_random_item(half_quartile)
		return;
	
	support_quote.text = get_random_item(top_quartile)


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
	rng.randomize()
	set_game_state(0)
	# Loads and plays the music with a crossfade
	MusicManager.play_music(preload("res://Music/mfcc-retro-arcade-game-music-297305.mp3"))
	pass # Replace with function body.

var change_direction_presses = 0

var fragment_line_scene = load("res://GameObjects/UI/FragmentLine.tscn")

var fragment_indictors = []

func setup_line_fragment(line_size: float):
	line_sections.clear()
	if (level_is_fragment == 0): #Tidy everything up as we'll not be using things in this cycle
		Global.set_line_sections(line_sections) #Make sure we annul this record
		Global.set_line_size(line_size)
		return line_size
	
	#Lets see about having breaks and offsets :)
	var long_line_size = line_size
	var fragment_dir = -1 #So that we can flip things to try and keep i interesint
	if (level_is_fragment == 2):
		fragment_dir = 1
	if (level_is_fragment < 3):
		var formation_type = rng.randi_range(0, 1)
		#formation_type = 1
		if (formation_type == 0):
			#Formation 1:
			#..123456
			#012..56789
			line_sections.append(Vector3(0, 300, 0))
			line_sections.append(Vector3(-line_size * 0.1, 300 + 100 * fragment_dir, line_size*0.3))
			line_sections.append(Vector3(-line_size * 0.4, 300, line_size * 0.9))
			long_line_size = line_size * 1.4
		if (formation_type == 1):
			#Formation 2:
			#..123456
			#01234..789
			line_sections.append(Vector3(0, 300, 0))
			line_sections.append(Vector3(-line_size * 0.3, 300 + 100 * fragment_dir, line_size*0.5))
			line_sections.append(Vector3(-line_size * 0.4, 300, line_size * 1.1))
			
			long_line_size = line_size * 1.4
	else: #This is a double fragment
		#.1234
		#01..56.89
		#.....1234
		#This one has been terrible to figure out. It'll do
		line_sections.append(Vector3(0, 300, 0))
		line_sections.append(Vector3(-line_size * 0.1, 300 + 100 * fragment_dir, line_size * 0.2))
		line_sections.append(Vector3(-line_size * 0.2, 300, line_size * 0.7))
		line_sections.append(Vector3(-line_size * 0.4, 300 - 100 * fragment_dir, line_size * 0.9))
		line_sections.append(Vector3(-line_size * 0.4, 300, line_size * 1.3))
		
		long_line_size = line_size * 1.4
		
	
	#PROBLEM: Need to keep a list/handle on the fragment lines we've got to disable them or reuse them
	#So here I've got to add in some graphics to indicate where everything is going to go
	for i in range(line_sections.size()-1):
		#Really this just involves linking the ends of the sections :)
		if (fragment_indictors.size() <= i):
			var new_fragment_line = fragment_line_scene.instance()
			fragment_indictors.append(new_fragment_line)
			$Background.add_child(new_fragment_line) #But we won't be able to see this behind the background
			
		var frag_start = Vector2(line_sections[i+1].z + line_sections[i].x, line_sections[i].y)
		var frag_end = Vector2(line_sections[i+1].z + line_sections[i+1].x, line_sections[i+1].y)
		fragment_indictors[i].position = frag_start
		fragment_indictors[i].set_point_positions(frag_end-frag_start)
		fragment_indictors[i].set_color(lerp(Color.white, Color.black, i/5.0))
	
	Global.set_line_sections(line_sections)
	Global.set_line_size(long_line_size)
	return long_line_size

func set_fragments():
	#Basically zero is showing nothing, fade our fragments off
	#Otherwise they need to be faded on and animated out
	print("Line Fragments")
	print(level_is_fragment)
	
	if (level_is_fragment == 0):
		if ($Background/BarBackingFragmentA.visible):
			var tween = $Background/BarBackingATween
			tween.stop_all()
			tween.remove_all()
			tween.interpolate_property($Background/BarBackingFragmentA, "modulate", Color.white, Color.transparent, 0.75, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			tween.connect("tween_all_completed", $Background/BarBackingATween, "set_visible", [false])

			tween.start()
		
		if ($Background/BarBackingFragmentB.visible):
			var tweenB = $Background/BarBackingBTween
			tweenB.stop_all()
			tweenB.remove_all()
			tweenB.interpolate_property($Background/BarBackingFragmentB, "modulate", Color.white, Color.transparent, 0.75, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			tweenB.connect("tween_all_completed", $Background/BarBackingBTween, "set_visible", [false])
			
			tweenB.start()
		
	if (level_is_fragment == 1 || level_is_fragment == 2): #Just one above or below
		$Background/BarBackingFragmentA.visible = true
		$Background/BarBackingFragmentA.modulate = Color.white
		$Background/BarBackingFragmentA.position = Vector2(492, 300)
		#var tween = create_tween()
		var vertical_pos = 200
		if (level_is_fragment == 2):
			vertical_pos = 400
		var tween = $Background/BarBackingATween
		tween.stop_all()
		tween.remove_all()
		
		tween.interpolate_property($Background/BarBackingFragmentA, "position", Vector2(492, 300), Vector2(492, vertical_pos), 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
	
	if (level_is_fragment == 3): #Both one above, and one below
		$Background/BarBackingFragmentA.visible = true
		$Background/BarBackingFragmentA.modulate = Color.white
		$Background/BarBackingFragmentA.position = Vector2(492, 300)
		#var tween = create_tween()
		
		var tween = $Background/BarBackingATween
		tween.interpolate_property($Background/BarBackingFragmentA, "position", Vector2(492, 300), Vector2(492, 200), 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.stop_all()
		tween.remove_all()
		tween.start()
		
		$Background/BarBackingFragmentB.visible = true
		$Background/BarBackingFragmentB.modulate = Color.white
		$Background/BarBackingFragmentB.position = Vector2(492, 300)
		#var tween = create_tween()
		
		var tweenB = $Background/BarBackingBTween
		tweenB.interpolate_property($Background/BarBackingFragmentB, "position", Vector2(492, 300), Vector2(492, 400), 1.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tweenB.stop_all()
		tweenB.remove_all()
		tweenB.start()
		
	#We also need to handle the visibility of our fragment indicators
	for i in range(fragment_indictors.size()):
		fragment_indictors[i].set_visibility(false)


func do_level_setup():
	if (randf() > 0.80 && level_is_fragment == 0):
		portal_system.enable_portals(true)
	else:
		portal_system.enable_portals(false)
	
	change_direction_presses = 0
	x_prompt.modulate = Color.white	#Turn our prompt panel back on again
	
	var line_size = get_viewport().get_visible_rect().size.x
	
	#So now I need a few more things
	#Lines to indicate where a section is jumpting to and from where
	#Some clever function to come up with a ton of different "fragments" for our system
	#A system that reflects this in the displayed lines on screen
	line_size = setup_line_fragment(line_size)
	
	max_score = int(SaveManager.get_value("max_score"))
	high_score_node.text = str(max_score)
	#Idea: break the screen up into sections and then use that logic for the placement of the character
	#This seems like a good idea, but it's not as it can start the player in situations where they cannot survive
	#var start_positions = [1, 2, 3, 4, 5, 6, 7]
	var startpos = floor(rand_range(1, 7))
	print (startpos)
	#PROBLEM: Speed_multiplier probably shouldn't be linear
	var speed_multiplier = lerp(1.0, 1.75, float(current_round)/20.0)
	
	#player_node.global_position = Vector2(startpos/7.0 * 1024, 300)
	player_node.set_line_position(startpos/7.0 * line_size)
	player_node.set_speed_multiplier(speed_multiplier)
	player_node.set_line_size(line_size)
	player_node.set_start_invincible()
	
	#Based off of our start pos we can now look at positioning our enemy
	var direction = [-1, 1][randi() % 2]
	var dirstartpos = direction * floor(rand_range(3, 7))
	#print (dirstartpos)
	var enemystartpos = startpos + dirstartpos
	
	enemystartpos = fposmod(enemystartpos, 8.0)	#Will need to make sure that this isn't zero
	#Ghost has to be not too close to the player, but we're simply prototyping at this stage
	#startpos = floor(rand_range(1, start_positions.size()))
	ghost_node.set_speed_multiplier(speed_multiplier)
	ghost_node.global_position =  Vector2(enemystartpos/7.0 * line_size, 300)
	ghost_node.reset_ghost()
	ghost_node.set_line_size(line_size)
	#print(enemystartpos)
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
		if (line.trigger == "powerup" && int(SaveManager.get_value("story_games")) > line.triggernum):
			necessary_pickup = line.powerup_reveal
			#Make sure we update our save manager so that this'll be unlocked from this point forward
			SaveManager.set_value("powerup_unlock", max(int(SaveManager.get_value("powerup_unlock")), necessary_pickup+1))
			create_callback_timer(0.75, "display_ingame_dialogue") # Remember to pull up our ingame dialogue
			
	var pickup_spawned = pips_node.spawn_pickups(true, true, player_node.global_position.x, necessary_pickup)
	#really we need a pause while the game presents the powerups that we might have unlocked
	if (start_powerups.size() > 0):
		apply_start_pickups()
	
	#var pickup_spawned = pips_node.spawn_pickups(true, true, player_node.global_position.x)
	level_start_time = Time.get_ticks_msec()
	
	#PROBLEM: We're going to need a clever way to figure out how much time 
	#the player should get in the level based off of everything that's happening
	
	#For the moment, fuckit
	game_timer.wait_time = 60.0
	game_timer.start()

func apply_start_pickups():
	#We need to present the powerups that the player has. This'll need some sort of extra screen. Yay
	
	for powerup in start_powerups:
		#Actually this should either go to our powerups boxes or be applied at start - that's more reasonable
		select_powerup(powerup.get("powerup_effect_tag"))
	
	start_powerups.clear() #reset our array 

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
		#Keep a ticker on our control prompt
		change_direction_presses = change_direction_presses + 1
		if (change_direction_presses == 3):
			#Modulate off our change direction prompt
			var tween = create_tween()
			tween.tween_property(x_prompt, "modulate:a", 0.0, 1.0)
		
		#Step forward with our screen setup
		if (Global.game_state != 2 && Global.game_state != 1 && bAllowInput):
			var new_game_state = Global.game_state # + 1
			if (UI_Menus[new_game_state]):
				if (get_node(UI_Menus[new_game_state]).has_method("handle_inputaction")):
					new_game_state = get_node(UI_Menus[new_game_state]).handle_inputaction(new_game_state)
				
			if (Global.game_state == 3): #Handle our end of level stuff
				#I want this to launch straight into the game now, so we're doing to subdivert this function
				if (current_round == 0):
					bHighscoreSet = false
					aggregate_score = 0	#Reset our aggregate score as this is a game start thing (this might need another stage)
				
				#new_game_state = 0;
				set_game_state(1)
				current_round += 1
				target_score = 100 + current_round * 100
				target_score_node.text = str(target_score)
				score = 0
				
				levelcomplete_screen.display_target(target_score)
				
			
			if (Global.game_state == 4):
				target_score = 100
				target_score_node.text = "100"
				score = 0
				new_game_state = 0;
				
			
			set_game_state(new_game_state)
	
	#Handle our display timer
	if (Global.game_state == 2):
		# time_left returns the time remaining in seconds
		var time_remaining = game_timer.time_left
		
		# Convert to minutes and seconds
		var minutes = int(time_remaining) / 60
		var seconds = int(time_remaining) % 60
		
		# Display formatted as MM:SS
		game_time_display.text = "%02d:%02d" % [minutes, seconds]

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
	
	apply_powerup(selected_powerup)	#Apply the powerup at level standard
	#The ghost
	#Some screen effefts thing
	#pass

func apply_powerup(new_powerup:String):
	match new_powerup:
		"pup_freeze":
			#Apply freeze effect to ghost's stats
			#print("Doing Ghost Freeze")
			#freeze_start = OS.get_ticks_msec()
			#bFreezeActive = true
			var tween = create_tween()
			effect_freeze.visible = true
			tween.tween_property(effect_freeze, "modulate:a", 0.75, 0.5)
			create_callback_timer(Global.freeze_duration, "freeze_callback")
			#Need to play some sort of freeze effect or animation
		"pup_invisible":
			#print("Doing player invisible")
			#invisible_start = OS.get_ticks_msec()
			#bInvisibleActive = true
			#Need to display a ? icon over the ghost to indicate that it's searching
			create_callback_timer(Global.invisible_duration, "invisible_callback")
		"pup_repulse":
			#print("Doint repulse action")
			#repulse_action_end = OS.get_ticks_msec() + Global.repulse_action_duration
			#bRepulseActive = true
			create_callback_timer(Global.repulse_action_duration, "repulse_callback")
		"pup_taser":
			#print("Doing taser action")
			#taser_action_end = OS.get_ticks_msec() + Global.taser_action_duration
			#btaserActive = true
			create_callback_timer(Global.taser_action_duration, "taser_callback")


func freeze_callback():
	var tween = create_tween()
	effect_freeze.visible = true
	tween.tween_property(effect_freeze, "modulate:a", 0.0, 0.5)
	tween.tween_callback(effect_freeze, "hide")

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

func player_teleported():
	ghost_node.set_confused(1.0)

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


func _on_GameLevelTimer_timeout():
	print("Time finished. Player dies")
	pass # Replace with function body.
