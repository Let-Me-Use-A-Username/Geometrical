class_name Upgrade 


enum UpgradeType {UTILITY, ABILITY, MAINSKILL}

var upgrade_name: String 
var upgrade_type: String
var upgrade_effect: String
var upgrade_description: String 
var upgrade_active: bool

var target_entity: CharacterBody2D


func apply_effect() -> bool:
	var success = false
	return success

func remove_effect() -> bool:
	var success = false
	return success
