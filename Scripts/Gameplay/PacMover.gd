extends MoverBase
class_name PacMover

var velocity = Vector2.ZERO
var speed = 200
#We need some adjustors for the speed zone
var speed_up = 1.5
var speed_down = 0.9

var bPlayer_alive = true
var bInvincible = false

export(Color) var color_normal
export(Color) var color_invisible

const SOUNDS = {
	"taser"   : preload("res://Sounds/Powerups/electric-zap.wav"),
	"freeze_start"	: preload("res://Sounds//Powerups/Freeze_Start.wav"),
	"freeze_end" : preload("res://Sounds//Powerups/Freeze_Stop.wav"),
	"invisible_start" : preload("res://Sounds//Powerups/Invisible_Start.wav"),
	"invisible_end" : preload("res://Sounds//Powerups/Invisible_Stop.wav")
}


#====Powerup effects================================
export(NodePath) var repel_effect_path
onready var repel_effect = get_node(repel_effect_path)

export(NodePath) var taser_effect_path
onready var taser_effect = get_node(taser_effect_path)

var sound_effect_die = preload("res://Sounds/GameEffects/freesound_community-086398_game-die-81356.mp3")

func _ready():
	# Get the viewport size
	#screen_size = get_viewport_rect().size
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
	
	#Handle the boost powerup
	if (bBoostActive):
		final_speed = final_speed * 1.2
	
	#Apply speed modifier and move
	velocity = input_vector * final_speed * speed_multiplier
	#move_and_slide(velocity, Vector2.UP)
	#position += velocity * delta
	do_position_move(velocity, delta) #Move our character on the line position
	
	# Wrap using a temporary variable
	#var new_pos = position
	if (line_position > screen_size ||line_position < 0):
		line_position = fposmod(line_position, screen_size)
		#new_pos.y = fposmod(new_pos.y, screen_size.y)
	
	#And NOW get our screen position given offsets :)
	position = Global.get_screen_position(Vector2(line_position, 300))
	#print(position)
	# Need to have a duplicate sprite here too

#So with this we've gone over something that can affect us in some way
func _on_CenterPointTrigger_area_entered(area):
	#To begin with we've got the teleporter areas which will require:
	#Callback to teleporter script
	#Teleporter script makes affected change
	if (area.has_method("pac_contacted")):
		area.pac_contacted(self)
	pass # Replace with function body.

func play_freeze_end_sound():
	play_sound(SOUNDS["freeze_end"])
	
func play_invisible_end_sound():
	play_sound(SOUNDS["invisible_end"])

func apply_powerup(new_powerup:String):
	.apply_powerup(new_powerup)
	
	match new_powerup:
		"pup_freeze":
			play_sound(SOUNDS["freeze_start"])
			var freeze_end_call_time = Global.freeze_duration - 1.4;
			create_callback_timer(freeze_end_call_time, "play_freeze_end_sound")
		"pup_invisible":
			var tween = create_tween()
			tween.tween_property(char_sprite, "modulate", color_invisible, 0.5)
			play_sound(SOUNDS["invisible_start"])
			create_callback_timer(Global.invisible_duration - 1.3, "play_invisible_end_sound")
			pass
		"pup_repulse":
			repel_effect.emitting = true
			pass
		"pup_taser":
			taser_effect.emitting = true
			play_sound(SOUNDS["taser"])
			pass
		"pup_boost":
			bBoostActive = true
			create_callback_timer(Global.boost_action_druation, "boost_callback")
			instance_motion_ghost()
			$GhostTimer.start()
			pass
			
func boost_callback():
	.boost_callback()
	$GhostTimer.stop()

func repulse_callback():
	.repulse_callback()
	repel_effect.emitting = false

func taser_callback():
	.taser_callback()
	taser_effect.emitting = false

func invisible_callback():
	.invisible_callback()
	var tween = create_tween()
	tween.tween_property(char_sprite, "modulate", color_normal, 0.5)

func ghost_ate_player():
	if (bInvincible || !bPlayer_alive):
		return #Can't kill the player right now, and can't kill what's already dead
	#Tell our level controller about it
	bPlayer_alive = false
	set_animation("Die")
	level_controller.ghost_ate_player()
	play_sound(sound_effect_die)
	
func end_start_invincible():
	bInvincible = false
#because there are some things I just can't seem to fix the easy way...
func set_start_invincible():
	bInvincible = true
	create_callback_timer(1.0, "end_start_invincible")

var motion_ghost_scene = preload("res://GameObjects/PowerupFX/MotionGhost.tscn")
func instance_motion_ghost():
	var ghost: Sprite = motion_ghost_scene.instance()
	get_parent().get_parent().add_child(ghost)

	ghost.global_position = global_position
	ghost.texture = char_sprite.texture
	ghost.vframes = char_sprite.vframes
	ghost.hframes = char_sprite.hframes
	ghost.frame = char_sprite.frame
	ghost.scale = char_sprite.scale


func _on_GhostTimer_timeout():
	instance_motion_ghost()
