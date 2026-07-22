extends Node2D

export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)

export(NodePath) var powerup_items_path
onready var powerup_items = get_node(powerup_items_path)

export(NodePath) var add_score_display_path
onready var add_score_display = get_node(add_score_display_path)

export (PackedScene) var pip_scene # Assign your pickup scene in inspector
export(Array, PackedScene) var special_pips = []

export (int) var num_pickups = 10	#Really this should be a density measure as I'd like to change the screensize
export (float) var pickup_density = 72
export (float) var screen_padding = 50

export(PackedScene) var override_powerup

var screen_size

var num_spawned_pickups = 11
var min_child_count = 5 #if we've this number or fewer we should start drifting to one side
var drift_velocity_min = 25
var drift_velocity_max = 100

#Any sounds that we could be playing in the scene when pellets are collected/interacted with
const SOUNDS = {
	"eat_pip" : preload("res://Sounds/GameEffects/vadim_makes_sound-retro-arcade-menu-navigate-554505.mp3")
}

export(NodePath) var sound_player_path
onready var sound_player = get_node(sound_player_path)

func play_sound(stream):
	if (sound_player == null):
		sound_player = get_node(sound_player_path)
	sound_player.stream = stream
	sound_player.play()

func spawn_pickups(bHasGhostPellet : bool, bHasSpecialPellet: bool, playerPosition : float, pickup_reveal = -1):
	self.position.x = 0 #Reset our position just in case we've drifted
	#we need to clear any pickups we may have had before putting down new ones
	for child in self.get_children():
		if child is Node2D:
			child.queue_free()
	
	screen_size = get_viewport_rect().size
	num_pickups = floor(Global.line_size / pickup_density);
	min_child_count = num_pickups * 0.6 #So as to have a dynamic line approach
	num_spawned_pickups = num_pickups
	
	var min_place_distance = 0.25 * 1024
	
	var start_pos = Vector2(screen_padding, 300)
	var end_pos = Vector2(Global.line_size - screen_padding, 300) #Vector2(screen_size.x - screen_padding, 300)
	
	var special_pickup = -1

	var special_placed = false
	
	for i in range(num_pickups):
		# Calculate factor t from 0.0 to 1.0
		var t = 0.0
		if num_pickups > 1:
			t = float(i) / (num_pickups - 1)
		
		var odds_special = (1.0 + i) / num_pickups
		
		var place_special = false
		# Linearly interpolate position
		var spawn_pos = start_pos.linear_interpolate(end_pos, t)
		if (!special_placed && abs(playerPosition - spawn_pos.x) < min_place_distance):
			if (rand_range(0.0, 1.0) < odds_special):
				#this is a special point, not a standard one
				place_special = true
				special_placed = true
		# Instance and add to scene
		
		var p
		if (!place_special):
			p = pip_scene.instance()
		else:
			#Need to override this with the unlock
			var max_powerup = 1;
			max_powerup = max(max_powerup, int(SaveManager.get_value("powerup_unlock")))
			max_powerup = min(max_powerup, special_pips.size())
			
			#PROBLEM: Hack for testing
			max_powerup = special_pips.size()
			
			var value = randi() % max_powerup
			if (pickup_reveal != -1): #Make sure our pickup is the one we're supposed to show
				#PROBLEM: Need to setup to pause game and deliver message
				value = pickup_reveal
			if (override_powerup==null):
				p = special_pips[value].instance()
			else:
				p = override_powerup.instance()
		
		if (p):
			p.parent_pickup_handler = self
			#p.position = spawn_pos
			p.set_line_position(spawn_pos)
			p.reveal_delay = i * 0.03
			add_child(p)
	
	return special_placed

func pellet_pickedup(pickup_item : Node, pickup_effect : String, add_value: int):
	if (Global.game_state != 2 || level_controller.level_start_time > Time.get_ticks_msec() - 50): #Needs a debounce for components to settle into location
		return
	#decrement our pickups, and win the level at 0
	num_spawned_pickups = num_spawned_pickups -1
	#might need some clever handling for scores
	var pickups_remaining = level_controller.add_score(add_value)
	if (self.get_child_count() == 1): #This was the last pickup
		print("Pips cleared")
		level_controller.pips_exhausted()
	
	#Need to swithc effects if we've got a command string through
	match pickup_effect:
		"eat_ghost":
			level_controller.do_powerup_eat_ghost()
	if (pickup_item != null && pickup_item.pickup_resource != null): #This is something to pass through to our other systems
		#print("Collected powerup")
		#PROBLEM: if the powerups are full we need to apply the effect of this powerup immediately
		var pickup_added = powerup_items.addPowerup(pickup_item.pickup_resource, pickup_item.global_position)
		if (!pickup_added):
			level_controller.select_powerup(pickup_item.pickup_resource.get("powerup_effect_tag"))
	else:
		play_sound(SOUNDS["eat_pip"])
		add_score_display.show_indicator(add_score_display.global_position, "+"+ str(add_value))
	
	if (pickup_item != null):
		pickup_item.queue_free()
	return pickups_remaining

func _physics_process(delta):
	#This needs a pause before it begins drifting for the player
	if (num_spawned_pickups <= min_child_count):
		#Need to figure out which direction we're going to drift
		var bounds = get_children_bounds_2d()
		#if ((bounds.x + bounds.y) * 0.5 > Global.line_size * 0.5):  #This isn't an effective approach
		if (bounds.x < Global.line_size - bounds.y):
			if (bounds.x > screen_padding):
				#I'd like to graduate our drift velocity so that it moves faster to shift the pips
				var drift_Vector = Vector2(-lerp(drift_velocity_max, drift_velocity_min, num_spawned_pickups/min_child_count), 0)
				#move_and_slide(drift_Vector)
				for child in self.get_children():
					child.apply_velocity(drift_Vector * delta)
		else:
			if (bounds.y < Global.line_size - screen_padding):
				#I'd like to graduate our drift velocity so that it moves faster to shift the pips
				var drift_Vector = Vector2(lerp(drift_velocity_max, drift_velocity_min, num_spawned_pickups/min_child_count), 0)
				#move_and_slide(drift_Vector)
				for child in self.get_children():
					child.apply_velocity(drift_Vector * delta)
		
		
func get_children_bounds_2d():
	var child_min = 99999
	var child_max = -10
	for child in self.get_children():
		if child is Node2D:
			# Get the child's global transform and size
			var child_transform = child.global_position
			child_min = min(child_transform.x, child_min)
			child_max = max(child_transform.x, child_max)

	# Convert the global rect back to local space relative to the parent
	return Vector2(child_min, child_max)

