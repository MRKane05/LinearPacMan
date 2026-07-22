# PointIndicatorManager.gd - add to AutoLoad in Project Settings
extends Node

export (PackedScene) var PointIndicator # Assign your pickup scene in inspector
#const PointIndicator = preload("res://GameObjects/UI/CollectDisplay.tscn")
const POOL_SIZE = 10

var _pool = []

func _ready():
	if (PointIndicator == null):
		PointIndicator = preload("res://GameObjects/UI/CollectDisplay.tscn")
	_initialise_pool()

func _initialise_pool():
	for i in POOL_SIZE:
		var indicator = PointIndicator.instance()
		indicator.z_index = 100
		indicator.visible = false
		add_child(indicator)
		_pool.append(indicator)

func get_indicator() -> Node:
	# Find the first inactive indicator
	for indicator in _pool:
		if not indicator.visible:
			return indicator
	
	# Pool exhausted - grow it dynamically rather than failing
	push_warning("PointIndicatorManager: pool exhausted, growing")
	var indicator = PointIndicator.instance()
	indicator.visible = false
	indicator.z_index = 100
	add_child(indicator)
	_pool.append(indicator)
	return indicator

func show_indicator(world_pos: Vector2, message: String, color = Color.white):
	if (Global.game_state != 2):
		return
	var indicator = get_indicator()
	indicator.global_position = world_pos
	indicator.display_message(message, color)
	indicator.visible = true
