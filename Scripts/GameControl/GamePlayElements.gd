extends Node

export(NodePath) var level_add_time_label_node
onready var add_time_label = get_node(level_add_time_label_node)

onready var animation_player = $AnimationPlayer

func show_add_time(ammount: float):
	animation_player.stop()
	add_time_label.visible = true
	add_time_label.text = "+" + str(ammount)
	animation_player.play("AddTimeToClock")
