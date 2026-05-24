extends UI_Menu

export(NodePath) var dialogue_text_path
onready var dialogue_text = get_node(dialogue_text_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	#display_dialogue(0)
	pass # Replace with function body.

func display_dialogue(record: int):
	# Get and iterate dialogue
	var line = StoryManager.get_dialogue(record)
	dialogue_text.text = line.lines[1];
	#print(line.text)
