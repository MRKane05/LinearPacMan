extends Node

func set_point_positions(end_offset: Vector2):
	$EndPoint.position = end_offset;
	
	# Set the start and end Vector2 positions
	#my_line.set_point_position(0, Vector2(100, 100)) # Start (Index 0)
	$Line2D.set_point_position(1, end_offset) # End (Index 1)
