extends Control

export (String) var volume_channel = "vol_master"
export (String) var bus_channel = "Master"

onready var slider = $HSlider

func _ready():
	#This will need to update it's posisition based off of memory cached values
	connect("visibility_changed", self, "_on_visibility_changed")
	load_volume_settings()

func load_volume_settings():
	var vol_master = float(SaveManager.get_value(volume_channel))
	set_bus_volume(bus_channel, vol_master)
	#Set the sliders without triggering a volume change
	slider.disconnect("value_changed", self, "_on_HSlider_value_changed")
	slider.value = vol_master
	slider.connect("value_changed", self, "_on_HSlider_value_changed")
	
func _on_visibility_changed():
	# Check if the node is actually visible
	if visible:
		_on_made_visible()

func _on_made_visible():
	pass

func set_bus_volume(bus_name: String, linear_value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	# Convert 0.0-1.0 linear range to decibels
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_value))

func linear_to_db(linear: float) -> float:
	var db_volume = lerp(-50, 0, linear/100.0)
	return db_volume
	
	if linear <= 0.0:
		return -80.0  # Effectively silent, avoid log(0) which is undefined
	return 20.0 * log(linear/100.0) / log(10.0)

func db_to_linear(db: float) -> float:
	return pow(10.0, db / 20.0) * 100.0

func _on_HSlider_value_changed(value: float):
	set_bus_volume(bus_channel, value)
	SaveManager.set_value(volume_channel, value)
	SaveManager.save_game()
