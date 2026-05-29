# SaveManager.gd - add to AutoLoad
extends Node

const PC_SAVE_PATH = "C://Users//kano//Documents//Projects//VitaGames//LinearPacMan//savegame.json"

var target_save_path = "ux0:data//LPAC//savegame.json" #Default to Vita unless otherwise specified

enum Platform { VITA, WINDOWS, LINUX, MAC, UNKNOWN }

var current_platform: int = Platform.UNKNOWN

func is_vita() -> bool:
	return current_platform == Platform.VITA

func is_desktop() -> bool:
	return current_platform in [Platform.WINDOWS, Platform.LINUX, Platform.MAC]

func get_platform_name() -> String:
	match current_platform:
		Platform.VITA:      return "PSVita"
		Platform.WINDOWS:   return "Windows"
		Platform.LINUX:     return "Linux"
		Platform.MAC:       return "Mac"
		_:                  return "Unknown"

# Define your save data structure with defaults
var save_data = {
	"max_score":       0,
	"total_games":     0,
	"story_games":     0, #Because games played is used as a trigger :)
	"story_index":     0,
	"playtime":        0.0,
	"powerup_unlock":	1,
	"gamemod_unlock":	0,
}

func _ready():
	match OS.get_name():
		"PSVita":   current_platform = Platform.VITA
		"Windows":  current_platform = Platform.WINDOWS
		"X11":      current_platform = Platform.LINUX
		"OSX":      current_platform = Platform.MAC
		_:          current_platform = Platform.UNKNOWN
	print("Platform detected: " + get_platform_name())
	
	if (!is_vita()):
		target_save_path = PC_SAVE_PATH;
	else:
		var dir = Directory.new()
		if (!dir.dir_exists("ux0:data//LPAC")):
			dir.make_dir("ux0:data//LPAC")
	
	load_game()

## SAVE
func save_game():
	var file = File.new()
	var error = file.open(target_save_path, File.WRITE)
	if error != OK:
		push_error("SaveManager: could not open save file for writing - " + str(error))
		return
	file.store_string(JSON.print(save_data, "\t"))
	file.close()
	print("Game saved successfully")

## LOAD
func load_game():
	var file = File.new()
	if not file.file_exists(target_save_path):
		print("SaveManager: no save file found, using defaults")
		save_game()
		return
	
	file.open(target_save_path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse(content)
	if result.error != OK:
		push_error("SaveManager: corrupt save file - " + result.error_string)
		return
	
	# Merge loaded data over defaults so new fields are handled safely
	for key in result.result:
		if save_data.has(key):
			save_data[key] = result.result[key]
	print("Save loaded successfully")

## DELETE
func delete_save():
	var dir = Directory.new()
	if dir.file_exists(target_save_path):
		dir.remove(target_save_path)
		save_data = {
			"max_score":       0,
			"total_games":     0,
			"story_games":     0, #Because games played is used as a trigger :)
			"story_index":     0,
			"playtime":        0.0,
			"powerup_unlock":	1,
			"gamemod_unlock":	0,
		}
		print("Save deleted")

## GETTERS AND SETTERS
func set_value(key: String, value) -> void:
	if not save_data.has(key):
		push_warning("SaveManager: unknown key '" + key + "'")
		return
	save_data[key] = value

func get_value(key: String):
	if not save_data.has(key):
		push_warning("SaveManager: unknown key '" + key + "'")
		return null
	return save_data[key]
