extends Area2D
class_name PointAffectorBase

#This class has a callback that's sent through from the pacman itself
#and from here we do something

func pac_contacted(affectee: Node2D):
	do_pac_contacted(affectee)

func do_pac_contacted(affectee: Node2D):
	pass
