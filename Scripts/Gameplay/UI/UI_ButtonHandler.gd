extends Button

export var bNeedsFocus = false

#I wanted to avoid having a reference to this here
export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)


#Used for simplified menu directed navigation
export(NodePath) var disable_node_path
onready var disable_node = get_node(disable_node_path)

export(NodePath) var enable_node_path
onready var enable_node = get_node(enable_node_path)

export var button_action_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if (bNeedsFocus):
		grab_focus()
		# Connect the signal to ourselves
		connect("visibility_changed", self, "_on_visibility_changed")

func _on_visibility_changed():
	# Check if the node is actually visible
	if visible:
		_on_made_visible()

func _on_made_visible():
	if (bNeedsFocus):
		yield(get_tree(), "idle_frame")
		# Keep yielding until we're actually visible in the tree
		while not is_visible_in_tree():
			yield(get_tree(), "idle_frame")
		focus_mode = Control.FOCUS_ALL
		grab_focus()
		#print("Focus grabbed, visible: ", is_visible_in_tree())

func on_Button_Pressed():
	#Need to pass an argument through as a function with this
	#In our case it's simply sending a command index through to the game controller
	if (button_action_index > 0):
		level_controller.set_game_menu_state(button_action_index)
	
	if (enable_node != null):
		enable_node.visible = true;
	
	if (disable_node != null):
		disable_node.visible = false

#I give up, these can be passthroughs
func _on_Button_StoryMode_pressed():
	on_Button_Pressed()


func _on_Button_Arcade_pressed():
	on_Button_Pressed()


func _on_Button_Options_pressed():
	#Don't actually have to do anything here
	on_Button_Pressed()


func _on_Button_Credits_pressed():
	#Don't actually have to do anything here
	on_Button_Pressed()


func _on_Button_Return_pressed():
	#Don't actually have to do anything here
	on_Button_Pressed()
