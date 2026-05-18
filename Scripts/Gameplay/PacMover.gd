extends MoverBase
class_name PacMover

var velocity = Vector2.ZERO
var speed = 200
#We need some adjustors for the speed zone
var speed_up = 1.5
var speed_down = 0.9

var screen_size

var bPlayer_alive = true

export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)

const SOUNDS = {
	"taser"   : preload("res://Sounds/Powerups/electric-zap.wav"),
}


#====Powerup effects================================
export(NodePath) var repel_effect_path
onready var repel_effect = get_node(repel_effect_path)

export(NodePath) var taser_effect_path
onready var taser_effect = get_node(taser_effect_path)

func _ready():
	# Get the viewport size
	screen_size = get_viewport_rect().size
	set_animation("Eat")
	
func reset_character():
	set_animation("Eat")
	bPlayer_alive = true

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
	
	if (!bPlayer_alive):	#we've died so don't move anywhere
		final_speed = 0
	
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
	
	
func apply_powerup(new_powerup:String):
	.apply_powerup(new_powerup)
	
	match new_powerup:
		"pup_freeze":
			pass
		"pup_invisible":
			pass
		"pup_repulse":
			repel_effect.emitting = true
			pass
		"pup_taser":
			taser_effect.emitting = true
			play_sound(SOUNDS["taser"])
			pass

func repulse_callback():
	.repulse_callback()
	repel_effect.emitting = false

func taser_callback():
	.taser_callback()
	taser_effect.emitting = false

func ghost_ate_player():
	#Tell our level controller about it
	bPlayer_alive = false
	set_animation("Die")
	level_controller.ghost_ate_player()

