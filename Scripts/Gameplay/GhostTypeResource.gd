extends Resource
class_name GhostTypeResource

export(Color) var ghost_tint = Color.red
export(Color) var ghost_glow = Color.red

export (float) var reaction_time = 0.5
export (float) var confuse_time = 0.5
export (float) var direction_change_speed = 1.0 #Something about how quickly we'll change direction
export (float) var max_speed_mod = 1.0 #Maybe one will be faster after accelerating?
export(float) var confuse_chance = 0.5
