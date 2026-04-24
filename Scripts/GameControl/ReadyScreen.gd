extends Node

export(NodePath) var target_text_path
onready var target_text = get_node(target_text_path)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func display_target(target):
	target_text.text = "Target: " + str(target);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
