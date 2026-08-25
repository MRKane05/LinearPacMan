extends Node2D

#I wanted to avoid having a reference to this here
export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)


#Used for simplified menu directed navigation
export(NodePath) var disable_node_path
var disable_node

export(NodePath) var enable_node_path
var enable_node

var menu_animator
export var reveal_animation = ""

func _ready():
	menu_animator = get_node_or_null("AnimationPlayer")
	
	if (disable_node_path != null && !disable_node_path.is_empty()):
		disable_node = get_node(disable_node_path)
	
	if (enable_node_path != null && !enable_node_path.is_empty()):
		enable_node = get_node(enable_node_path)
	connect("visibility_changed", self, "_on_visibility_changed")

func _on_visibility_changed():
	# Check if the node is actually visible
	if visible:
		_on_made_visible()

func _on_made_visible():
	if (menu_animator && reveal_animation.length() > 3):
		menu_animator.play(reveal_animation)

#This script works with the intention of allowing the user to close a panel with a button
func _process(delta):
	#Need to look for a cancell press
	if Input.is_action_just_pressed("ui_cancel") || Input.is_action_just_pressed("ui_select"):
		close_window()
	pass

func close_window():
	#this window action might need to send something through to our 
	#game manager so that it can resume functionality
	
	if (enable_node != null):
		enable_node.visible = true
	
	if (disable_node):
		disable_node.visible = false
