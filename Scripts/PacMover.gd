extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 200

var screen_size

func _ready():
	# Get the viewport size
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	# Basic character movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = 0 #Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity = input_vector.normalized() * speed
	move_and_slide(velocity)
	
	# Wrap the character position
	position.x = posmod(position.x, screen_size.x)
	position.y = posmod(position.y, screen_size.y)
	
	# Need to have a duplicate sprite here too
