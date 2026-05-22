extends Node
class_name PowerupDisplayHandler

export(NodePath) var level_controller_path
onready var level_controller = get_node(level_controller_path)

export(Array, NodePath) var PowerupBoxes = []	#Our display boxes!
export(Array, Resource) var CollectedPowerups = []	#What powerups have we collected?
export(Array, String) var CollectedPowerupEffectTags = []
export(Array, Resource) var PowerupItemList = []

#This class is intended to handle the powerups that the player has collected
func _ready():
	#CollectedPowerups.resize(3) #Pre-prepare our array
	CollectedPowerupEffectTags.resize(3)
	#We'd also be wise to fetch all our nodes instead of doint them when something is called

#I've got no idea how to do this

#This needs to allot collected powerups to slots
#Activate when a button is pressed
#Button press sends command through to system to effect powerup
#Remove from allotment and repopulate icons accordingly

#This is being called twice?
func addPowerup(powerup_resource: Resource, startPosition: Vector2):
	for item in PowerupItemList:
		if (item == powerup_resource):
			#Go through our avaliable collectedPowerups to find an open box
			for i in 3:
				if (CollectedPowerupEffectTags[i] == null):
					print ("powerup collected")
					print (powerup_resource.powerup_name)
					CollectedPowerupEffectTags[i] = powerup_resource.powerup_effect_tag #This stores the resources that are allotted to our powerup buttons
					var powerup_box = get_node(PowerupBoxes[i]); #We need tog et an object reference here to display this
					#var player_node = get_node(player_node_path)
					#see about setting this amongst our powerups, but for the moment...
					powerup_box.set_icon_sprite(item.powerup_icon, startPosition)
					#We need to have some animation showing that this has been collected
					break
	#This needs some sort of failstate if we don't have a gap

func use_powerup(index: int):
	if (CollectedPowerupEffectTags[index] != null):
		print (CollectedPowerupEffectTags[index])
		level_controller.select_powerup(CollectedPowerupEffectTags[index])
		CollectedPowerupEffectTags[index] = null
		var powerup_box = get_node(PowerupBoxes[index]) #We need tog et an object reference here to display this
		powerup_box.set_icon_sprite(null, Vector2.ZERO)
		
	pass

func _process(delta):
	#Handle our inputs and map accordingly
	if Input.is_action_just_pressed("ui_cancel"):
		use_powerup(0)
	if Input.is_action_just_pressed("ui_select"):
		use_powerup(1)
	if Input.is_action_just_pressed("ui_square"):
		use_powerup(2)

