extends MoverBase

var velocity = Vector2.ZERO
var speed = 220
var flee_speed = 250
var flee_position = 0
var slow_speed = 180

export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

export(Color) var color_normal
export(Color) var color_frozen

var bCanBeEaten = false
var bGhostFlee = false
var bGhostRespawning = false
var bGhost_Confused = false

var respawn_pause = 3000

var function_time = 0

var sprite_side_buffer = 24

var taser_action_timer;
var bIstasered = false

func _setup_counters():
	#taser timer
	taser_action_timer = Timer.new()
	taser_action_timer.name = "taser_action_timer"
	add_child(taser_action_timer)  # Only add if newly created
	pass
	#This is where we setup the counters for anything that affects us (powerup effects)


func _ready():
	# Get the viewport size
	#screen_size = get_viewport_rect().size
	# We need to know what our player is
	char_sprite.material.set_shader_param("scroll_speed", 1.0)
	char_sprite.material.set_shader_param("scroll_direction", 1.0)
	set_animation("Move")

func set_scroll_speed(speed: float):
	char_sprite.material.set_shader_param("scroll_speed", speed)

func set_scroll_direction(direction: float):
	char_sprite.material.set_shader_param("scroll_direction", direction)


func reset_ghost():
	bCanBeEaten = false;
	bGhostFlee = false;
	bGhostRespawning = false
	set_animation("Move")
	char_sprite.modulate = color_normal
	#Might need to reset any animation state here

func _physics_process(delta):
	if (!visible):
		return #disable this function
	# Basic character movement
	var input_vector = Vector2.ZERO
	input_vector.x = sign(player_node.global_position.x - position.x); # Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = 0; #Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	#=======Hande Powerup Check Functions
	if (bInvisibleActive || bGhost_Confused):
		#We need to affect our input_vector.x to give some sort of random movement
		if (OS.get_ticks_msec() > invislbe_dir_change_time):
			invislbe_dir_change_time = OS.get_ticks_msec() + rand_range(750, 1500)
			invisible_current_dir = rand_range(0, 4)
			invisible_current_dir = floor(invisible_current_dir) - 1
			
			if (invisible_current_dir == 0):
				set_animation("Search_Still")
			else:
				set_animation("Search_Move")
			
		input_vector.x = invisible_current_dir
		#PROBLEM: Need to have effects for looking confused
		
	
	if (!bInvisibleActive && !bGhostRespawning && !bGhost_Confused):
		set_animation("Move")
	
	if (btaserActive):
		if (abs(player_node.global_position.x - position.x) < taser_distance):
			got_tazed_end = OS.get_ticks_msec() + Global.got_tazed_duration
			#PROBLEM: Need to play some effect for gettting tazed
	
	
	if (bCanBeEaten):	#We need to flee our player
		set_animation("Flee")
		input_vector.x *= -1
	
	var move_speed = speed
	#Lazy state machine==================================================
	if (bCanBeEaten || bInvisibleActive || bGhost_Confused):
		move_speed = slow_speed
	
	#===Powerup affectors========================================
	if (bFreezeActive):
		move_speed *= freeze_speed_factor
	
	#========State for ghost eaten========================
	if (bGhostFlee):
		set_animation("Eaten")
		move_speed = flee_speed
		input_vector.x = sign(flee_position - position.x) #Change our target position
		#Need to check if we're within our position and then do a respawn action
		if (abs(flee_position - position.x) < 5):
			bGhostFlee = false
			bGhostRespawning = true
			set_animation("Respawn")
			function_time = Time.get_ticks_msec() + respawn_pause	#When will we finish respawning?
			print(function_time)
			
	if (bGhostRespawning):
		
		move_speed = 0 #Stay where we are for the respawn
		if (Time.get_ticks_msec() > function_time):
			bGhostRespawning = false
			bCanBeEaten = false
			
	
	#Apply speed modifier
	#move_speed = move_speed * speed_multiplier
	
	#Send information through for our animation systems
	#set_scroll_direction(input_vector.x) #Scroll direction is sorted by the mirroring
	set_moveDir(sign(input_vector.x))
	velocity = input_vector.normalized() * move_speed * speed_multiplier
	#======Handle repuse Powerup=======================
	if (bRepulseActive && abs(player_node.global_position.x - position.x) < repulse_distance_max):
		#Need to push the ghost back and away from the player, somehow...
		var repulseDistance = abs(player_node.global_position.x - position.x) - repulse_distance_min;
		repulseDistance = repulseDistance / (repulse_distance_max - repulse_distance_min);
		velocity += repulseDistance * input_vector.normalized() * repulse_max_force
	
	if (OS.get_ticks_msec() < got_tazed_end): #We've been tazed, so annul our movement
		velocity.x = 0
	
	move_and_slide(velocity)
	if (position.x < sprite_side_buffer):
		position.x = sprite_side_buffer
	if (position.x > screen_size - sprite_side_buffer):
		position.x = screen_size - sprite_side_buffer

func _on_Area2D_body_entered(body):
	#in theory this'll only be the player that we can contact with
	#notify the game system that we've touched the player
	#do the player die sequence
	if body.name == "PacMan":
		if bCanBeEaten && !bGhostFlee && !bGhostRespawning && Global.game_state == 2:
			print("Player ate the ghost!")
			bGhostFlee = true
			bCanBeEaten = false
			#Set our ghost flee position to the other quarter point on the screen from where we were caught as we'll logically be in a corner
			if (position.x < screen_size/2):
				flee_position = screen_size * 0.75
			else:
				flee_position = screen_size * 0.25
		else:
			if (!bGhostFlee && !bGhostRespawning && Global.game_state == 2):
				player_node.ghost_ate_player()
				print("Ghost killed the player!")
	pass # Replace with function body.
	

func apply_powerup(new_powerup:String):
	.apply_powerup(new_powerup)
	match new_powerup:
		"pup_freeze":
			var tween = create_tween()
			tween.tween_property(char_sprite, "modulate", color_frozen, 0.5)
			pass
		"pup_invisible":
			#So that our ghost predictibly looks confused when the player vanishes
			invislbe_dir_change_time = OS.get_ticks_msec() + rand_range(750, 1500)
			invisible_current_dir = 0
			set_animation("Search_Still")
		"pup_repulse":
			pass
		"pup_taser":
			pass
			
func freeze_callback():
	.freeze_callback()
	var tween = create_tween()
	tween.tween_property(char_sprite, "modulate", color_normal, 0.5)

func ghost_confused():
	bGhost_Confused = false

func set_confused(duration: float):
	set_animation("Search_Still")
	bGhost_Confused = true
	create_callback_timer(duration, "ghost_confused")
	invislbe_dir_change_time = OS.get_ticks_msec() + rand_range(750, 1500)
	invisible_current_dir = 0
	pass
