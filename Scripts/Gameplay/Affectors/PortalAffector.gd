extends PointAffectorBase
class_name PortalAffector

export(NodePath) var portal_base_node_path
onready var portal_base = get_node(portal_base_node_path)
export (bool) var bportal_right = true

func do_pac_contacted(affectee: Node2D):
	.do_pac_contacted(affectee) #Call to our super
	portal_base.do_pac_contacted(affectee, bportal_right)

