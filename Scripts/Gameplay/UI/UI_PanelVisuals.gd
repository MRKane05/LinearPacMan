extends Sprite
#A script designed to handle extra visuals on panels themselves

# Declare member variables here. Examples:
func _process(delta):
	# Example: Pulse brightness over time using a sine wave
	var val = 1.0 + (sin(Engine.get_frames_drawn() * 0.1) + 1.0) * 0.125
	material.set_shader_param("brightness", val)
