extends Node


export(NodePath) var portal_right_node_path
onready var portal_right = get_node(portal_right_node_path)

export(NodePath) var portal_left_node_path
onready var portal_left = get_node(portal_left_node_path)

func do_pac_contacted(pac_node : Node2D, bwas_right: bool):
	#So, we've had a contact on one of our portals and need to put the player
	#into a different location
	#First we need to move the player
	#Then we need to flip the players direction
	print(pac_node.global_position)
	#Get the move direction of the player as this'll need flipped and this defines the offset
	var moveDir = pac_node.moveDir * -1
	var step_threshold = 10;
	if (bwas_right):
		pac_node.global_position.x = portal_left.global_position.x + moveDir * step_threshold
	else:
		pac_node.global_position.x = portal_right.global_position.x + moveDir * step_threshold
	print(pac_node.global_position)
	pac_node.set_moveDir(moveDir)
