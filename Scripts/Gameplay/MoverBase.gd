extends KinematicBody2D
class_name MoverBase

export(NodePath) var char_sprite_path
onready var char_sprite = get_node(char_sprite_path)

#What powerups are affecting us?
export(Array, Resource) var AffectedPowerups = []

var boost_type = 0
var moveDir = 1

#This could do with being part of a base class
func set_boostzone(new_boost_type):
	#boost types: 0, none, 1 left, 2, right, 3 both
	boost_type = new_boost_type
	pass

func set_moveDir(new_moveDir: float):
	moveDir = new_moveDir
	char_sprite.scale.x = moveDir * 0.25 #PROBLEM: This is terrible coding for handling temp sprites

func apply_powerup(new_powerup:String):
	pass

func clear_powerups():
	pass
