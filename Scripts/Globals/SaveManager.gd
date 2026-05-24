# SaveManager.gd - add to AutoLoad
extends Node

const SAVE_PATH = "C://Users//kano//Documents//Projects//VitaGames//LinearPacMan//savegame.json"

# Define your save data structure with defaults
var save_data = {
	"max_score":       0,
	"total_games":     0,
	"story_games":     0, #Because games played is used as a trigger :)
	"story_index":     0,
	"playtime":        0.0,
	"powerup_unlock":	0,
	"gamemod_unlock":	0,
}

func _ready():
	load_game()

## SAVE
func save_game():
	var file = File.new()
	var error = file.open(SAVE_PATH, File.WRITE)
	if error != OK:
		push_error("SaveManager: could not open save file for writing - " + str(error))
		return
	file.store_string(JSON.print(save_data, "\t"))
	file.close()
	print("Game saved successfully")

## LOAD
func load_game():
	var file = File.new()
	if not file.file_exists(SAVE_PATH):
		print("SaveManager: no save file found, using defaults")
		save_game()
		return
	
	file.open(SAVE_PATH, File.READ)
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
	print("Game loaded successfully")

## DELETE
func delete_save():
	var dir = Directory.new()
	if dir.file_exists(SAVE_PATH):
		dir.remove(SAVE_PATH)
		save_data = {
			"max_score":       0,
			"total_games":     0,
			"story_games":     0, #Because games played is used as a trigger :)
			"story_index":     0,
			"playtime":        0.0,
			"powerup_unlock":	0,
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
