extends Node

#Game Control values
var game_state = 0


var freeze_duration = 4.0
var invisible_duration = 5.0
var repulse_action_duration = 1.5
var taser_action_duration = 0.750	#Very short action time
var boost_action_druation = 1.5
var got_tazed_duration = 2.0
var additional_time_duration = 5.0
var timer_pause_duration = 3.0

var time_score_value = 12.0


#Send up our line_fragments to make it easier for everything to refernce this
var line_sections = []
var line_size = 0

var bCanAcceptInput = true

func set_can_accept_input(new_input_state):
	print ("Setting allow input")
	print(new_input_state)
	bCanAcceptInput = new_input_state

func set_line_size(new_line_size: float):
	line_size = new_line_size

func set_line_sections(new_line_sections):
	line_sections = new_line_sections

func get_screen_position(position: Vector2):
	#Compare this linear position against the array of offsets
	#Return a corrected position for fragmented lines
	var current_section = 0
	if (line_sections != null && line_sections != []):
		if (line_sections.size() > 0):
			for i in line_sections.size():
				if (position.x > line_sections[i].z):
					current_section = i
		else:
			return position
	else:
		return position
	#Finally apply and return our offset
	return Vector2(position.x + line_sections[current_section].x, line_sections[current_section].y)
