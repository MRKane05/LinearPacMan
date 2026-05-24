extends Node

onready var canvas_layer = get_tree().root.get_node("SceneBase/Camera2D")

enum MENU_LEVEL {
	NONE,
	MAIN 
		# ...
}

var menus = {
	#MENU_LEVEL.MAIN: preload("res://scenes/main_menu.tscn").instantiate(),
}
var current_menu

func load_menu(menu_level):
	var container = canvas_layer.find_child("menu", false, false)
	if not container:
		var menu_node = Node.new()
		menu_node.set_name("menu")
		canvas_layer.add_child(menu_node)
		container = menu_node
	
	for menu_child in container.get_children():
		container.remove_child(menu_child)
	
	if menu_level != MENU_LEVEL.NONE:
		current_menu = menus[menu_level]
		container.add_child(current_menu)
