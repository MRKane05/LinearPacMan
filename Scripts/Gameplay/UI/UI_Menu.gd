extends Node2D
class_name UI_Menu

export var return_var = -1 #This is hard-coded to return something when the player presses action

#A base class that'll be used as an interface with the different UI
#  elements for handling how calls get sorted/intercepted through the UI
#  as we're just using a simple base class to read button presses

func handle_inputaction(gamestate: int):
	if (return_var == -1):
		return gamestate + 1 #base behaviour is to increment this by one
	return return_var
