extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 200
var moveDir = 1

var screen_size

func _ready():
	# Get the viewport size
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	if (!visible):
		return #disable this function
	# Basic character movement
	var input_vector = Vector2.ZERO
	if Input.is_action_just_pressed("ui_accept"):
		moveDir = moveDir * -1
	input_vector.x = moveDir; #Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = 0 #Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity = input_vector * speed
	move_and_slide(velocity, Vector2.UP)
	
	# Wrap using a temporary variable
	var new_pos = position
	if (new_pos.x > screen_size.x || new_pos.x < 0):
		new_pos.x = fposmod(new_pos.x, screen_size.x)
		new_pos.y = fposmod(new_pos.y, screen_size.y)
		position = new_pos
	
	# Need to have a duplicate sprite here too
