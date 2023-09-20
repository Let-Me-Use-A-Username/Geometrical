class_name Upgrade_factory extends Node


var upgrades: Dictionary
var upgrade_trees: Dictionary
var available_trees: Dictionary
var applied_upgrades: Array

@onready var player = owner as Player

var total_coins = 0

#read abilities from a txt file 
func _init() -> void:
	var file = FileAccess.open("res://src/Scenes/Objects/PlayerAbilities/skills.txt", FileAccess.READ)
	var line = file.get_line()
	while !file.eof_reached():
		var values = line.split(",")
		if values.size() > 3:
			var upgrade = Upgrade.new()
			upgrade.upgrade_name = values[0].strip_edges(true, true)
			upgrade.upgrade_type = values[1].strip_edges(true, true)
			upgrade.upgrade_effect = values[2].strip_edges(true, true)
			upgrade.upgrade_description = values[3].strip_edges(true, true)
			upgrade.upgrade_active = false
			upgrades[values[0]] = upgrade
			line = ""
		line = file.get_line()


func _ready() -> void:
	upgrade_trees = {
		"Utility" : {},
		"MainSkill" : {},
		"Ability" : {},
		"AbilityUpgrade" : {}
		}
	_prepare_tree()


#prepares the trees that the player chooses from
func _prepare_tree() -> void:
	for _upgrade in upgrades.keys():
		var type = upgrades.get(_upgrade).upgrade_type
		match type.strip_edges(true, true):
			"U":
				upgrade_trees["Utility"][_upgrade] = upgrades.get(_upgrade)
			"M":
				upgrade_trees["MainSkill"][_upgrade] = upgrades.get(_upgrade)
			"A":
				upgrade_trees["Ability"][_upgrade] = upgrades.get(_upgrade)
			"AU":
				upgrade_trees["AbilityUpgrade"][_upgrade] = upgrades.get(_upgrade)
			_:
				pass
	available_trees = upgrade_trees


func _print_upgradeTrees() -> void:
	for type in upgrade_trees:
		print("Type: ", type, "\n")
		for upgrade in upgrade_trees.get(type):
			print("Name: ", upgrade)
			print("Effects: ", upgrade_trees[type][upgrade].upgrade_effect)
			print("Description: ", upgrade_trees[type][upgrade].upgrade_description)
		


#exports the tree (trees) to player
func _export_tree(coins) -> Dictionary:
	total_coins = coins
	_remove_used_upgrades()
	_append_next_level_upgrades()
	_get_available_tree()
	return available_trees


#The idea is that we have a list with all of the upgrades. 
#When the player levels up he is able to choose from 4 upgrades 
#DEPENDING on how long he has been playing and what upgrades he already has 
#Different choices should be available for him
func _get_available_tree() -> void:
	if total_coins == 50:
		pass
		#choose ability


func _append_next_level_upgrades() -> void:
	pass


func _remove_used_upgrades() -> void:
	#_print_upgradeTrees()
	for type in available_trees:
		for upgrade in available_trees[type]:
			if available_trees[type][upgrade].upgrade_active == true:
				available_trees[type].erase(upgrade)


func _get_random_upgrades(ab_name: String) -> Array:
	randomize()
	var returnee = []
	var value = available_trees[ab_name].values()
	for repeat in range(0, 3):
		var upgrade = value.pick_random()
		returnee.append(upgrade)
		value.erase(upgrade)
	return returnee



func apply_effect(ability: Upgrade) -> void:
	var upgrade_effect = ability.upgrade_effect
	var target_attribute 
	
	if "+" in upgrade_effect:
		target_attribute = upgrade_effect.split("+")
		var stats = player._get(target_attribute[0])
		if stats != null:
			var increment = stats[1] + stats[1] * (float(target_attribute[1])/100)
			var suc = player._set(stats[0], increment)
			if suc:
				applied_upgrades.append(ability)
				print_debug("Successfully upgraded: ", stats[0], " to: ", increment)
			else:
				print_debug("Failed to upgrade: ", stats[0])


func remove_effect(ability: Upgrade) -> void:
	pass


func _get_applied_upgrades() -> Array:
	return applied_upgrades
