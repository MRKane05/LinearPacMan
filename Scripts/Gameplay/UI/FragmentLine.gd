extends Node

func set_point_positions(end_offset: Vector2):
	$EndPoint.position = end_offset;
	# Set the start and end Vector2 positions
	#my_line.set_point_position(0, Vector2(100, 100)) # Start (Index 0)
	$Line2D.set_point_position(1, end_offset) # End (Index 1)
	#And we should do a reveal on these also
	set_visibility(true)

func set_visibility(is_visible: bool):
	var tween = $Tween
	tween.stop_all()
	tween.remove_all()
	
	# Clean up any existing completion signal
	if tween.is_connected("tween_all_completed", self, "set_visible"):
		tween.disconnect("tween_all_completed", self, "set_visible")
	
	if is_visible:
		self.visible = true  # Must be visible before fading in
		tween.interpolate_property(self, "modulate", Color.transparent, Color.white, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	else:
		tween.interpolate_property(self, "modulate", Color.white, Color.transparent, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.connect("tween_all_completed", self, "set_visible", [false])
	
	tween.start()
