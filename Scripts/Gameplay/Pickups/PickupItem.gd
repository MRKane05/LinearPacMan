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

func _ready():
	if (timer && reveal_delay > 0):
		timer.wait_time = reveal_delay
		timer.one_shot = true
		timer.connect("timeout", self, "do_reveal")
		timer.start()
	else:
		do_reveal()
	pass


func do_reveal():
	if (animation_player):
		animation_player.play(start_animation)

func _on_GenericPip_body_entered(body):
	# only the player can interact with this object
	# need to call through to the level controller to say we've collected
	if (parent_pickup_handler != null):
		parent_pickup_handler.pellet_pickedup(self, pickup_effect, pickup_value)
	# do our collect animation
	# Remove the item from the scene
	#queue_free()
	
	

func _on_Timer_timeout():
	do_reveal()
