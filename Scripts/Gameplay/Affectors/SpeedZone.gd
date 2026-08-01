extends Area2D

#Zone types: 1: Right, 2: Left, 3: both
export (int) var zone_type = 1
export (bool) var affect_player = true

export(NodePath) var backing_sprite_path
onready var backing_sprite = get_node(backing_sprite_path)

export(NodePath) var direction_sprite_path
onready var direction_sprite = get_node(direction_sprite_path)

export(NodePath) var bidirection_sprite_path
onready var bidirection_sprite = get_node(bidirection_sprite_path)

export var backing_spirte_color = Color.yellow

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	backing_sprite.modulate = backing_spirte_color
	#set_sprite_visibility()
	rng.randomize()

func set_sprite_visibility():
	zone_type = rng.randi_range(0, 2)
	match zone_type:
		0:
			scale.x = -1
		1: 
			scale.x = 1
		2:
			scale.x = 1
	
	if (zone_type != 2):
		direction_sprite.visible = true
		bidirection_sprite.visible = false
	else:
		direction_sprite.visible = false
		bidirection_sprite.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_object_boostzone(body, entered: bool):
	if (body.has_method("set_boostzone")):
		if (entered):
			body.set_boostzone(zone_type)
		else:
			body.set_boostzone(-1)	#Turn this off
	pass


func _on_Area2D_body_entered(body):
	if (!visible):
		return
	if (affect_player):
		var isPlayer = (body.name == "PacMan")
		if (isPlayer):
			set_object_boostzone(body, true)
	else:
		var isGhost = (body.name == "Ghost")
		if (isGhost):
			set_object_boostzone(body, true)


func _on_Area2D_body_exited(body):
	print(body.name)
	var isPlayer = body.name == "PacMan"
	var isGhost = (body.name == "Ghost")
	if ((isPlayer && affect_player) || (isGhost && !affect_player)):
		set_object_boostzone(body, false)
