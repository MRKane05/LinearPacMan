# StoryManager.gd - recommended as AutoLoad
extends Node

var story_data = {}

func _ready():
	load_story("res://data/story.json")

func load_story(path: String):
	var file = File.new()
	
	# Check the file exists before trying to open it
	if not file.file_exists(path):
		push_error("StoryManager: file not found at " + path)
		return
	
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	
	var result = JSON.parse(content)
	if result.error != OK:
		push_error("StoryManager: JSON parse error - " + result.error_string)
		return
	
	story_data = result.result
	print("Story loaded successfully")

	# Get all dialogue for a scene
func get_dialogue(record: int) -> Dictionary:
	
	if (record < story_data.dialogue.size()):
		return story_data.dialogue[record]
	
	#for chapter in story_data.dialogue:
	#	if chapter.id == record_str:
	#		return chapter
	push_warning("StoryManager: chapter not found - " + str(record))
	return {}
	
func get_node_number():
	return story_data.dialogue.size()
