extends Node2D

onready var label = $Label
onready var anim = $AnimationPlayer

func display_message(message: String, color = Color.white):
	label.text = message
	label.self_modulate = color
	#animator_node.current_animation = "DoDisplay"
	anim.stop();
	anim.play("DoDisplay")

func _return_to_pool():
	modulate.a = 1.0  # Reset alpha for reuse
	visible = false

func _on_AnimationPlayer_animation_finished(anim_name):
	_return_to_pool()
