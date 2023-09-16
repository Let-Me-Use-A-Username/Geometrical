class_name Upgrade_factory extends Node


var upgrades: Dictionary
var upgrade_trees: Dictionary


#read abilities from a txt file 
func _init() -> void:
	var file = FileAccess.open("res://src/Scenes/Objects/PlayerAbilities/skills.txt", FileAccess.READ)
	var line = file.get_line()
	while !file.eof_reached():
		var values = line.split(",")
		if values.size() > 3:
			upgrades[values[0]] = [values[1], values[2], values[3]]
			line = ""
		line = file.get_line()
	_prepare_tree()


func _ready() -> void:
	upgrade_trees["Utility"] = {}			#U
	upgrade_trees["MainSkill"] = {}			#M
	upgrade_trees["Ability"] = {}			#A
	upgrade_trees["Ability_upgrades"] = {}	#AU


#prepares the trees that the player chooses from
func _prepare_tree() -> void:
	for upgrade_name in upgrades:
		var type
		match upgrades[upgrade_name][0]:
			"U":
				type = "Utility"
			"M":
				type = "MainSkill"
			"A":
				type = "Ability"
			"AU":
				type = "AbilityUpgrade"
			_:
				type = null
		
		if type != null:
			upgrade_trees[type] = { upgrade_name: upgrades[upgrade_name] }

#exports the tree (trees) to player
func _export_tree() -> void:
	pass
