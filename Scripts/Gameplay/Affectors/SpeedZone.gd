extends Area2D

#Zone types: 1: Right, 2: Left, 3: both
export (int) var zone_type = 1
export (bool) var affect_player = true

export(NodePath) var direction_sprite_path
onready var direction_sprite = get_node(direction_sprite_path)

export(NodePath) var bidirection_sprite_path
onready var bidirection_sprite = get_node(bidirection_sprite_path)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	set_sprite_visibility()
	pass # Replace with function body.

func set_sprite_visibility():
	match zone_type:
		0: #this shouldn't be possible
			pass
		1: 
			scale.x = 1
		2: 
			scale.x = -1
		3:
			scale.x = 1
	
	if (zone_type != 3):
		direction_sprite.show()
		bidirection_sprite.hide()
	else:
		direction_sprite.hide();
		bidirection_sprite.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_object_boostzone(body, entered: bool):
	if (body.has_method("set_boostzone")):
		if (entered):
			body.set_boostzone(zone_type)
		else:
			body.set_boostzone(0)	#Turn this off
	pass


func _on_Area2D_body_entered(body):
	print(body.name)
	var isPlayer = (body.name == "PacMan")
	if (isPlayer && affect_player):
		set_object_boostzone(body, true)
	pass # Replace with function body.


func _on_Area2D_body_exited(body):
	print(body.name)
	var isPlayer = body.name == "PacMan"
	if (isPlayer && affect_player):
		set_object_boostzone(body, false)
	pass # Replace with function body.
