extends Node2D

export var return_var = -1 #This is hard-coded to return something when the player presses action


export(NodePath) var target_text_path
onready var target_text = get_node(target_text_path)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func display_target(target):
	target_text.text = "Target: " + str(target);

func handle_inputaction(gamestate: int):
	if (return_var == -1):
		return gamestate + 1 #base behaviour is to increment this by one
	return return_var

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
