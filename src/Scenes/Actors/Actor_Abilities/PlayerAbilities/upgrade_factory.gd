class_name Upgrade_factory extends Node


#Upgrades read from the txt
var upgrades: Dictionary
#ALL UPGRADES
var upgrade_trees: Dictionary
#Available upgrades for the player
var available_trees: Dictionary
#Upgrades the player has chosen
var applied_upgrades: Array

@onready var player = owner as Player

#read abilities from a txt file 
func _init() -> void:
	var file = FileAccess.open("res://src/Scenes/Actors/Actor_Abilities/PlayerAbilities/skills.txt", FileAccess.READ)
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
	
	var fake_tree = {}
	fake_tree = _get_available_tree(coins)
	return fake_tree


func _get_available_tree(total_coins: int) -> Dictionary:
	var fake_tree = {}
	fake_tree["Utility"] = available_trees["Utility"]
	fake_tree["MainSkill"] = available_trees["MainSkill"]
	fake_tree["Ability"] = {}
	
	var _size = 0
	
	for upgrade in applied_upgrades:
		if upgrade.upgrade_type == "A":
			_size += 1
			
	print("Coins in Possession: ", total_coins)
	
	match _size:
		0:
			if total_coins > 7:
				for ability in available_trees["Ability"]:
					if ability == "Rings" or ability == "Timefreeze" or ability == "Explotion":
						fake_tree["Ability"][ability] = available_trees["Ability"][ability]
		1:
			if total_coins > 25:
				for ability in available_trees["Ability"]:
					if ability == "Supercharge" or ability == "Gunslinger" or ability == "Spaceshift":
						fake_tree["Ability"][ability] = available_trees["Ability"][ability]
		2:
			if total_coins > 45:
				for ability in available_trees["Ability"]:
					print("Ability name ", ability)
					var upgrade = available_trees["Ability"][ability]
					if upgrade not in applied_upgrades:
						print("Not applied ")
						fake_tree["Ability"][ability] = upgrade
						
	print("fake tree ", fake_tree)
	return fake_tree


func _append_next_level_upgrades() -> void:
	pass


func _remove_used_upgrades(upgrades: Dictionary) -> void:
	#_print_upgradeTrees()
	for type in upgrades:
		for upgrade in upgrades[type]:
			if upgrades[type][upgrade].upgrade_active == true:
				upgrades[type].erase(upgrade)


func _get_random_upgrades(ab_name: String) -> Array:
	randomize()
	var returnee = []
	var value = available_trees[ab_name].values()
	#Removing abilities that the player has chose
	match ab_name:
		"Ability":
			var repeat = 0
			while repeat != 3:
				var upgrade = value.pick_random()
				if upgrade in applied_upgrades:
					value.erase(upgrade)
					continue
				returnee.append(upgrade)
				value.erase(upgrade)
				repeat += 1
			return returnee
	#Different case for all the other upgrades that can be picked again
		_:
			for repeat in range(0, 3):
				var upgrade = value.pick_random()
				returnee.append(upgrade)
				value.erase(upgrade)
			return returnee



func apply_effect(ability: Upgrade) -> void:
	var upgrade_effect = ability.upgrade_effect
	var upgrade_type = ability.upgrade_type
	var target_attribute 
	var charge
	
	if upgrade_type == "U" or upgrade_type == "M":
		if "+" in upgrade_effect:
			target_attribute = upgrade_effect.split("+")
			charge = true
		else:
			target_attribute = upgrade_effect.split("-")
			charge = false
			
		var stats = player._get(target_attribute[0])
		if stats != null:
			var increment
			#When abilities are not percentage based they will handled differently
			match stats[0]:
				"dash_count":
					increment = stats[1] + int(target_attribute[1])
				_:
					if charge:
						increment = stats[1] + stats[1] * (float(target_attribute[1])/100)
					else:
						increment = stats[1] - stats[1] * (float(target_attribute[1])/100)
			
			
			var suc = player._set(stats[0], increment)
			if suc:
				ability.upgrade_active = true
				applied_upgrades.append(ability)
				print_debug("Successfully upgraded: ", stats[0], " to: ", increment)
			else:
				print_debug("Failed to upgrade: ", stats[0])
				
	elif upgrade_type == "A":
		if player._player_abilities.size() < 4:
			
			var applied_ability = Ability.new()
			applied_ability.ability_name = ability.upgrade_name
			applied_ability.ability_description = ability.upgrade_description
			var effects = ability.upgrade_effect.split("|")
			applied_ability.ability_cooldown = effects[1]
			
			if effects[0].split("=")[0] == "duration":
				applied_ability.ability_duration = effects[0].split("=")[1]
				applied_ability.ability_damage = 0
			else:
				applied_ability.ability_damage = effects[0].split("=")[1]
				applied_ability.ability_duration = 0.3
			
			applied_ability.ability_cooldown_timer = Timer.new()
			applied_ability.ability_cooldown_timer.set_wait_time(applied_ability.ability_cooldown)
			applied_ability.ability_cooldown_timer.set_one_shot(true)
			
			applied_ability.ability_duration_timer = Timer.new()
			applied_ability.ability_duration_timer.set_wait_time(applied_ability.ability_duration)
			applied_ability.ability_cooldown_timer.set_one_shot(true)
			
			applied_ability.ability_active = true
			#Player receives a different object of the ability
			player._player_abilities.push_back(applied_ability)
			#The factory keeps it the same
			applied_upgrades.append(ability)
			print_debug("Successfully added ability: ", applied_ability.ability_name)


func remove_effect(ability: Upgrade) -> void:
	pass


func _get_applied_upgrades() -> Array:
	return applied_upgrades
