extends MoverBase

export(Array, Resource) var ghost_types = []

var velocity = Vector2.ZERO
var speed = 220
var max_speed = 220
var flee_speed = 250
var flee_position = 0
var slow_speed = 180

#I want to start adding in the option of different colours for ghosts
#and thus altered behavior. What we have for behavior ideas is:
var reaction_speed = 0.5 #Milliseconds to change direction
var confuse_time = 0.5
var acceleration = 1.0 #Something about how quickly we'll change direction
var max_speed_mod = 1.0 #Maybe one will be faster after accelerating?
var direction_change_speed = 1.0
var last_face_dir = 0
var confuse_chance = 0.5
var bConfused = false
var bDirectionChangeDelay = false

export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

export(Color) var color_normal
export(Color) var color_frozen
export(Color) var color_flee

var bCanBeEaten = false
var bGhostFlee = false
var bGhostRespawning = false
var bGhost_Confused = false

var respawn_pause = 2000

var function_time = 0

var sprite_side_buffer = 24

var speed_dampen = 0.7 #How much is our speed dampened when going over the slow zone?

var bBeenTased = false

var player_height = 0 #for when we've a fractal level, if the player is below us this is changed to -1, above is 1

const SOUNDS = {
	"eaten"   : preload("res://Sounds/GameEffects/eatGhost_floraphonic-8-bit-game-6-188105.wav")
}


func _ready():
	# Get the viewport size
	#screen_size = get_viewport_rect().size
	# We need to know what our player is
	char_sprite.material.set_shader_param("scroll_speed", 1.0)
	char_sprite.material.set_shader_param("scroll_direction", 1.0)
	set_move_animation()

func set_scroll_speed(speed: float):
	char_sprite.material.set_shader_param("scroll_speed", speed)

func set_scroll_direction(direction: float):
	char_sprite.material.set_shader_param("scroll_direction", direction)


func reset_ghost():
	if (bCanBeEaten):
		var tween = create_tween()
		tween.tween_property(char_sprite, "modulate", color_normal, 0.5)
	bCanBeEaten = false;
	bGhostFlee = false;
	bGhostRespawning = false
	bBeenTased = false
	set_move_animation()
	char_sprite.modulate = color_normal
	last_face_dir = 0
	#Might need to reset any animation state here
	
	#Setup our ghost stats!
	var ghost_resource = rand_range(0, ghost_types.size())
	char_sprite.modulate = ghost_types[ghost_resource].ghost_tint
	color_normal = ghost_types[ghost_resource].ghost_tint
	$GlowSprite.modulate = ghost_types[ghost_resource].ghost_glow
	
	reaction_speed = ghost_types[ghost_resource].reaction_time
	confuse_chance = ghost_types[ghost_resource].confuse_chance
	confuse_time = ghost_types[ghost_resource].confuse_time
	direction_change_speed = ghost_types[ghost_resource].direction_change_speed
	max_speed_mod = ghost_types[ghost_resource].max_speed_mod

func set_move_animation():
	if (bBeenTased):#A quick little handler here
		set_animation("Shock")
		return
	if (bConfused):
		set_animation("Search_Still")
		return
	
	if player_height < 0:
		set_animation("Move_LookDown")
	elif player_height > 0:
		set_animation("Move_LookUp")
	else:
		set_animation("Move")

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
			#A little helper for handling how our ghost animates with a fragmented level
		if (level_controller.level_is_fragment > 0):
			var pac_relative = sign(position.y - player_node.position.y)
			if (pac_relative != player_height):
				player_height = pac_relative
				set_move_animation() 
	
	if (btaserActive && !bBeenTased):
		if (abs(player_node.global_position.x - position.x) < taser_distance):
			create_callback_timer(Global.got_tazed_duration, "taser_effect_finish")
			bBeenTased = true
			set_move_animation()
	
	
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
			
	if (bGhostRespawning):
		move_speed = 0 #Stay where we are for the respawn
		if (Time.get_ticks_msec() > function_time):
			bGhostRespawning = false
			bCanBeEaten = false
			var tween = create_tween()
			tween.tween_property(char_sprite, "modulate", color_normal, 0.5)

	#Create some sort of acceleration behavior for our ghost:
	if (input_vector.x != last_face_dir && last_face_dir != 0):
		last_face_dir = input_vector.x
		bConfused = rand_range(0.0, 1.0) < confuse_chance
		
		if (!bConfused && reaction_speed > 0):
			bDirectionChangeDelay = true
			create_callback_timer(reaction_speed, "direction_change_delay")
		elif (confuse_time > 0):
			bDirectionChangeDelay = true
			create_callback_timer(confuse_time, "direction_change_delay")
		
		set_move_animation() 
	
	#Send information through for our animation systems
	#This is where we'd put in our little behavioral quirks:
	if (bDirectionChangeDelay):
		input_vector.x = -last_face_dir
		if (bConfused): #Be confused on the spot
			move_speed = 0
	else:
		last_face_dir = input_vector.x
	
	var target_velocity = input_vector.normalized() * move_speed * speed_multiplier
	
	
	set_moveDir(sign(input_vector.x))
	
	
	match boost_type:
		-1: #Don't do anything
			#velocity = speed
			pass
		0: #Only going right
			if (moveDir > 0):
				target_velocity = target_velocity * speed_dampen
		1:	#Only going left
			if (moveDir < 0):
				target_velocity = target_velocity * speed_dampen
		2: #Bidirectional
			target_velocity = target_velocity * speed_dampen
	
	
	#======Handle repuse Powerup=======================
	if (bRepulseActive && abs(player_node.global_position.x - position.x) < repulse_distance_max):
		#Need to push the ghost back and away from the player, somehow...
		var repulseDistance = abs(player_node.global_position.x - position.x) - repulse_distance_min;
		#repulseDistance = clamp(repulseDistance, 0.0, 1.0)
		repulseDistance = repulseDistance / (repulse_distance_max - repulse_distance_min);
		target_velocity += repulseDistance * input_vector.normalized() * repulse_max_force * speed_multiplier
		#target_velocity = velocity #Try clamping this to prevent the ghost from overrunning the player now that we've got velocities
	
	velocity = lerp(velocity, target_velocity * max_speed_mod, delta * direction_change_speed * speed_multiplier)
	
	
	
	
	if (bBeenTased): #We've been tazed, so annul our movement
		velocity.x = 0
	
	#move_and_slide(velocity)
	do_position_move(velocity, delta) #Move our character on the line position
	
	if (line_position < sprite_side_buffer):
		line_position = sprite_side_buffer
	if (line_position > screen_size - sprite_side_buffer):
		line_position = screen_size - sprite_side_buffer
	
	position = Global.get_screen_position(Vector2(line_position, 300))
	

func ghost_can_be_eaten():
	bCanBeEaten = true
	var tween = create_tween()
	tween.tween_property(char_sprite, "modulate", color_flee, 0.5)

func direction_change_delay():
	bConfused = false;
	bDirectionChangeDelay = false;
	set_move_animation() 

func _on_Area2D_body_entered(body):
	#in theory this'll only be the player that we can contact with
	#notify the game system that we've touched the player
	#do the player die sequence
	if body.name == "PacMan":
		if bCanBeEaten && !bGhostFlee && !bGhostRespawning && Global.game_state == 2:
			print("Player ate the ghost!")
			bGhostFlee = true
			bCanBeEaten = false
			level_controller.pips_node.pellet_pickedup(null, "ghost", 50) #Update our points system
			PointIndicatorManager.show_indicator(global_position, "-5") #Display the points we just go
			play_sound(SOUNDS["eaten"])
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

func taser_effect_finish():
	bBeenTased = false
	set_move_animation()
