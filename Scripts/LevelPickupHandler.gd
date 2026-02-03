extends KinematicBody2D

export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)

export (PackedScene) var pickup_scene # Assign your pickup scene in inspector
export (int) var num_pickups = 10	#Really this should be a density measure as I'd like to change the screensize
export (float) var pickup_density = 72
export (float) var screen_padding = 50

var screen_size

var num_spawned_pickups = 11
var min_child_count = 2 #if we've this number or fewer we should start drifting to one side
var drift_velocity = 25

func _ready():
	# Get the viewport size
	
	#spawn_pickups(true, false)
	pass

func spawn_pickups(bHasGhostPellet : bool, bHasSpecialPellet: bool):
	screen_size = get_viewport_rect().size
	num_pickups = floor(screen_size.x / pickup_density);
	num_spawned_pickups = num_pickups
	
	var start_pos = Vector2(screen_padding, 300)
	var end_pos = Vector2(screen_size.x - screen_padding, 300)
	
	for i in range(num_pickups):
		# Calculate factor t from 0.0 to 1.0
		var t = 0.0
		if num_pickups > 1:
			t = float(i) / (num_pickups - 1)
		
		# Linearly interpolate position
		var spawn_pos = start_pos.linear_interpolate(end_pos, t)
		
		# Instance and add to scene
		var p = pickup_scene.instance()
		p.parent_pickup_handler = self
		p.position = spawn_pos
		add_child(p)
		
func pellet_pickedup(pickup_effect : String):
	#decrement our pickups, and win the level at 0
	num_spawned_pickups = num_spawned_pickups -1
	
	if (num_spawned_pickups <= 0):
		print("Level cleared")
	
	#Need to swithc effects if we've got a command string through

func _physics_process(delta):
	#This needs a pause before it begins drifting for the player
	if (num_spawned_pickups <= min_child_count):
		var bounds = get_children_bounds_2d()
		if (bounds.x > screen_padding):
			var drift_Vector = Vector2(-drift_velocity, 0)
			move_and_slide(drift_Vector)
		
		
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

