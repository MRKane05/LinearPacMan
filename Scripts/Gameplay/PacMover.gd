extends MoverBase
class_name PacMover

var velocity = Vector2.ZERO
var speed = 200
#We need some adjustors for the speed zone
var speed_up = 1.5
var speed_down = 0.9


var screen_size

#PROBLEM: We need a function set_move_dir for the starting state that also handles the sprite direction

func _ready():
	# Get the viewport size
	screen_size = get_viewport_rect().size
	

func _physics_process(delta):
	var final_speed = speed
	if (!visible):
		return #disable this function
	# Basic character movement
	var input_vector = Vector2.ZERO
	if Input.is_action_just_pressed("ui_accept"): #This should be the cross button
		set_moveDir(moveDir * -1)
	
	input_vector.x = moveDir; #Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = 0 #Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	match boost_type:
		0: #Don't do anything
			final_speed = speed
		1: #Only going right
			if (moveDir > 0):
				final_speed = speed * speed_up
		2:	#Only going left
			if (moveDir < 0):
				final_speed = speed * speed_up
		3: #Bidirectional
			final_speed = speed * speed_up
	
	velocity = input_vector * final_speed
	move_and_slide(velocity, Vector2.UP)
	
	# Wrap using a temporary variable
	var new_pos = position
	if (new_pos.x > screen_size.x || new_pos.x < 0):
		new_pos.x = fposmod(new_pos.x, screen_size.x)
		new_pos.y = fposmod(new_pos.y, screen_size.y)
		position = new_pos
	
	# Need to have a duplicate sprite here too

#So with this we've gone over something that can affect us in some way
func _on_CenterPointTrigger_area_entered(area):
	#To begin with we've got the teleporter areas which will require:
	#Callback to teleporter script
	#Teleporter script makes affected change
	if (area.has_method("pac_contacted")):
		area.pac_contacted(self)
	pass # Replace with function body.
