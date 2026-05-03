extends TextureRect
class_name UIPowerupIcon

export(NodePath) var icon_sprite_path
onready var icon_sprite = get_node(icon_sprite_path)

#This is also used to clear the sprite, so perhaps we could have something
#to animate it :)
func set_icon_sprite(newSprite: Texture):
	print("Sprite call set")
	icon_sprite.texture = newSprite
