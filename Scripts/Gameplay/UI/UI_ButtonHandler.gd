extends Button

export var bNeedsFocus = false

#I wanted to avoid having a reference to this here
export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)


#Used for simplified menu directed navigation
export(NodePath) var disable_node_path
var disable_node

export(NodePath) var enable_node_path
var enable_node

export var button_action_index = 0

export var special_action = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	if (disable_node_path != null && !disable_node_path.is_empty()):
		disable_node = get_node(disable_node_path)
	
	if (enable_node_path != null && !enable_node_path.is_empty()):
		enable_node = get_node(enable_node_path)

	
	if (bNeedsFocus):
		grab_focus()
		# Connect the signal to ourselves
		connect("visibility_changed", self, "_on_visibility_changed")
	connect("focus_entered", self, "_on_focus_entered")
	connect("pressed", self, "on_Button_Pressed")

func _on_focus_entered():
	MusicManager.play_menu_move_sound()
	
func _on_pressed():
	MusicManager.play_menu_confirm_sound()

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
	_on_pressed()
	if (button_action_index > 0):
		level_controller.set_game_menu_state(button_action_index)
	
	if (special_action.length() > 3):
		level_controller.run_special_action(special_action)
	
	if (enable_node != null):
		enable_node.visible = true;
	
	if (disable_node != null):
		disable_node.visible = false
