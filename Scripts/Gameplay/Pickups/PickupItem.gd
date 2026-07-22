extends Area2D
export (String) var pickup_effect = ""
export (String) var start_animation = "GenericPip_Start"
export (int) var pickup_value = 10
export (Resource) var pickup_resource

onready var animation_player = $AnimationPlayer
onready var timer = $Timer

var parent_pickup_handler = null
# Optional: Add audio or effects
# export(AudioStream) var pickup_sound

var reveal_delay = 0.0;

var line_position = 0

func _ready():
	if (timer && reveal_delay > 0):
		timer.wait_time = reveal_delay
		timer.one_shot = true
		timer.connect("timeout", self, "do_reveal")
		timer.start()
	else:
		do_reveal()
	pass

func set_line_position(new_position: Vector2):
	#Somehow we've got to get our positioning information here
	line_position = new_position
	position = Global.get_screen_position(Vector2(line_position.x, 300))
	pass

func apply_velocity(velocity: Vector2):
	#Apply a move velocity, and then the set_position
	line_position += velocity
	position = Global.get_screen_position(Vector2(line_position.x, 300))
	pass

func do_reveal():
	if (animation_player):
		animation_player.play(start_animation)

func _on_GenericPip_body_entered(body):
	# only the player can interact with this object
	# need to call through to the level controller to say we've collected
	var collects_remaining = 0
	if (parent_pickup_handler != null):
		collects_remaining = parent_pickup_handler.pellet_pickedup(self, pickup_effect, pickup_value)
		
		if (pickup_resource):
			var pickup_name = pickup_resource.get("powerup_name")
			var pickup_color = pickup_resource.get("powerup_color")
			PointIndicatorManager.show_indicator(global_position, pickup_name, pickup_color)
		else:
			#I want to know how many points are remaining after this has been collected...
			#PointIndicatorManager.show_indicator(global_position, "+" + str(pickup_value) + "\n" + str(collects_remaining))
			PointIndicatorManager.show_indicator(global_position, str(collects_remaining))
			
			
	# do our collect animation
	# Remove the item from the scene
	#queue_free()
	
	

func _on_Timer_timeout():
	do_reveal()
