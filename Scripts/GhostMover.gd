extends KinematicBody2D

var velocity = Vector2.ZERO
var speed = 220

var screen_size
export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

func _ready():
	# Get the viewport size
	screen_size = get_viewport_rect().size
	# We need to know what our player is
	

func _physics_process(delta):
	# Basic character movement
	var input_vector = Vector2.ZERO
	input_vector.x = sign(player_node.global_position.x - position.x); # Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = 0; #Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	velocity = input_vector.normalized() * speed
	move_and_slide(velocity)


func _on_Area2D_body_entered(body):
	#in theory this'll only be the player that we can contact with
	#notify the game system that we've touched the player
	#do the player die sequence
	if body.name == "PacMan":
		print("Player touched the enemy!")
	pass # Replace with function body.
