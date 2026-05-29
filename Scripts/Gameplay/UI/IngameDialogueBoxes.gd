extends DialogueScreen

export(NodePath) var dialogue_box_path
onready var dialogue_box = get_node(dialogue_box_path)

export(NodePath) var powerup_hint_path
onready var powerup_hint = get_node(powerup_hint_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func display_dialogue_powerup():
	#This box also brings up our powerup hint for using powerups
	dialogue_box.visible = true
	powerup_hint.visible = true
	do_display_dilogue()
	pass

func display_dialogue_character():
	#This path simply displays information to the player in the game (such as getting a note)
	dialogue_box.visible = true
	do_display_dilogue()
	pass

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		#Step forward with our screen setup
		#This will cycle our dialogue box more than anything else
		var handle_input = handle_inputaction(0)
		if (handle_input == 2):
			get_tree().paused = false #Not totally sure how we'll unpause given the current setup...
			self.visible = false
