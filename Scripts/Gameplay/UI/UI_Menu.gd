extends Node2D
class_name UI_Menu

export var return_var = -1 #This is hard-coded to return something when the player presses action

export(NodePath) var speaker_icon_path
onready var speaker_icon = get_node(speaker_icon_path)

export(Array, Texture) var speaker_icons = []

export(NodePath) var dialogue_text_path
onready var dialogue_text = get_node(dialogue_text_path)

export(NodePath) var speaker_name_path
onready var speaker_name = get_node(speaker_name_path)


#A base class that'll be used as an interface with the different UI
#  elements for handling how calls get sorted/intercepted through the UI
#  as we're just using a simple base class to read button presses

func handle_inputaction(gamestate: int):
	if (return_var == -1):
		return gamestate + 1 #base behaviour is to increment this by one
	return return_var

func set_speaker_icon(icon_entry: int):
	speaker_icon.texture = speaker_icons[icon_entry]

func set_speaker_icon_name_text(icon_entry: int, name: String, message: String):
	set_speaker_icon(icon_entry)
	speaker_name.text = name
	dialogue_text.text = message

func set_speaker_icon_name(icon_entry: int, name: String):
	set_speaker_icon(icon_entry)
	speaker_name.text = name
