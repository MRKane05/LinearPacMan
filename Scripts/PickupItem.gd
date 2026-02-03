extends Area2D
export (String) var pickup_effect = ""

var parent_pickup_handler = null
# Optional: Add audio or effects
# export(AudioStream) var pickup_sound

func _on_GenericPip_body_entered(body):
	# only the player can interact with this object
	# need to call through to the level controller to say we've collected
	if (parent_pickup_handler != null):
		parent_pickup_handler.pellet_pickedup(pickup_effect)
	# do our collect animation
	# Remove the item from the scene
	queue_free()
	print("Item collected!")
	
	
