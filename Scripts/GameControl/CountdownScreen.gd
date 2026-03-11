extends Node

export(NodePath) var levelcontrol_node_path
onready var levelcontrol_node = get_node(levelcontrol_node_path)

var finish_time = 0
var countdown_time = 3000
var bCountdownActive = false

# Called when the node enters the scene tree for the first time.
func start_countdown():
	bCountdownActive = true
	finish_time = Time.get_ticks_msec() + countdown_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (bCountdownActive):
		var num_time = str(ceil((finish_time-Time.get_ticks_msec())/1000.0))
		$CountDownInt.text = num_time
		#Now do our countdown circular graphic
		var num_frac = fposmod((finish_time-Time.get_ticks_msec())/1000.0, 1.0)
		$TextureProgress.value = num_frac * 100
		
		if (Time.get_ticks_msec() > finish_time):
			levelcontrol_node.set_game_state(2)	
			bCountdownActive = false#Set our game actually playing
