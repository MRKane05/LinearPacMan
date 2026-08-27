extends UI_Menu

class_name DialogueScreen


export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)

var current_line = 0
var story_node;

onready var sound_player = $AudioStreamPlayer2D

const SOUNDS = {
	"standard"   : preload("res://Sounds/UI/pac_standard.wav"),
	"thought"	: preload("res://Sounds/UI/pac_thought.wav"),
	"sad"	:	preload("res://Sounds/UI/pac_sad.wav"),
	"unsure" : preload("res://Sounds/UI/pac_unsure.wav"),
	"attention" :preload("res://Sounds/UI/pac_attention.wav")
}

func handle_inputaction(gamestate: int):
	if (story_node):	#Logically this'll be the one that was setup in the do_display_dioluge, but if not...
		if (current_line < story_node.lines.size()-1):
			current_line = current_line + 1;
			display_dialogue()
			return gamestate
		else:	#Move onto what should be our next screen (I assume it'll be the next game screen)
			#Need to increment our current story record by one
			var story_index = SaveManager.get_value("story_index")
			story_index = story_index + 1
			
			var games_played = int(SaveManager.get_value("total_games"))
			games_played = games_played - 1	#because we're going to spit everything back through our system
		
			SaveManager.set_value("total_games", games_played)
			
			if (story_index > StoryManager.get_node_number()):
				story_index = StoryManager.get_node_number()
			SaveManager.set_value("story_index", story_index)
			SaveManager.set_value("story_games", -1)
			if (return_var == -1):
				return gamestate + 1 #base behaviour is to increment this by one
			
			#There's a possibility that our game could be paused at this point
			#so we might need to unpause it to continue with normal function (if it's a ingame dialogue)
			level_controller.dialogue_pause = false
			level_controller.set_game_paused(false)
			return return_var
	else:
		do_display_dilogue()
		return 0
	
	if (return_var == -1):
		return gamestate + 1 #base behaviour is to increment this by one
	return return_var

func do_display_dilogue():
	current_line = 0
	var story_index = int(SaveManager.get_value("story_index"))
	story_node = StoryManager.get_dialogue(story_index)
	level_controller.dialogue_pause = true
	display_dialogue()

func display_dialogue():
	# Get and iterate dialogue
	#var line = StoryManager.get_dialogue(record)
	if (story_node):
		var story_line = story_node.lines[current_line]
		var line_parts = story_line.split('|')
		dialogue_text.text = line_parts[0]
		var speaker_name = story_node.speaker
		var graphic_entry = 1
		if ("?" in speaker_name):
			graphic_entry = 0
		SaveManager.set_value("pac_reveal", graphic_entry) #so that our system will show the correct icon while giving support text to the player
		#speaker_name.text = story_node.speaker;
		set_speaker_icon_name(graphic_entry, speaker_name)
		var speaker_sound = "standard"
		if (line_parts.size() == 2): #We've got a sound attached to this line that's different
			speaker_sound = line_parts[1].strip_edges()
			
		play_sound(SOUNDS[speaker_sound])

func play_sound(stream):
	sound_player.stream = stream
	sound_player.play()
