extends TextureRect
class_name UIPowerupIcon

export(NodePath) var icon_sprite_path
onready var icon_sprite = get_node(icon_sprite_path)

export(NodePath) var button_icon_path
onready var button_icon = get_node(button_icon_path)

var base_position = Vector2.ZERO


func _ready():
	base_position = icon_sprite.global_position
	modulate = Color(1,1,1,0.5)
	button_icon.modulate = Color(1,1,1,0.5)
	
#This is also used to clear the sprite, so perhaps we could have something
#to animate it :)
func set_icon_sprite(newSprite: Texture, startPosition: Vector2):
	if (newSprite != null):
		modulate = Color.white
		button_icon.modulate = Color.white
		icon_sprite.texture = newSprite
		#var tween = create_tween()
		icon_sprite.global_position = startPosition
		play_collect_arc(startPosition, base_position, 0.5)
	else:
		icon_sprite.texture = newSprite
		modulate = Color(1,1,1,0.5)
		button_icon.modulate = Color(1,1,1,0.5)

func play_collect_arc(start_pos: Vector2, end_pos: Vector2, duration: float = 1.2):
	var tween_x = create_tween()
	tween_x.tween_property(
		icon_sprite, "global_position:x",
		end_pos.x, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	var tween_y = create_tween()
	tween_y.tween_property(
		icon_sprite, "global_position:y",
		end_pos.y, duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = lerp(p0, p1, t)# p0.lerp(p1, t)
	var q1 = lerp(p1, p2, t) #p1.lerp(p2, t)
	return lerp(q0, q1, t) #q0.lerp(q1, t)

func _process(delta):
	pass
	
