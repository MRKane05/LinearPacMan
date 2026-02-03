extends Node

#This script needs to handle level timing and title displays
#setup level before the game starts
#get a callback when all pips have been completed and consider the level closed
#get a callback when the player dies and do a reset on the system

export(NodePath) var player_node_path
onready var player_node = get_node(player_node_path)

export(NodePath) var ghost_node_path
onready var ghost_node = get_node(ghost_node_path)

export(NodePath) var pips_node_path
onready var pips_node = get_node(pips_node_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	do_level_setup();
	pass # Replace with function body.

func do_level_setup():
	var start_positions = [1, 2, 3, 4, 5]
	var startpos = floor(rand_range(1, start_positions.size()))
	start_positions.remove(startpos)
	
	player_node.global_position = Vector2(startpos/6 * 1024, 300)
	#Ghost has to be not too close to the player, but we're simply prototyping at this stage
	startpos = floor(rand_range(1, start_positions.size()))
	ghost_node.global_position =  Vector2(startpos/6 * 1024, 300)
	
	pips_node.spawn_pickups(true, false)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


