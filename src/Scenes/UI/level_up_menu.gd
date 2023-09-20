extends Control


signal upgraded(ability: Upgrade)

@onready var skill_tree_1 = get_node("Menu/HBoxContainer/P_Utility")
@onready var skill_tree_2 = get_node("Menu/HBoxContainer/G_Utility")
@onready var skill_tree_3 = get_node("Menu/HBoxContainer/MainSkill")
@onready var skill_tree_4 = get_node("Menu/HBoxContainer/Ability")

@onready var option_1 = get_node("Abilities/HBoxContainer/#1")
@onready var option_2 = get_node("Abilities/HBoxContainer/#2")
@onready var option_3 = get_node("Abilities/HBoxContainer/#3")

@onready var player = get_node("../Player")
@onready var upgrade_factory = get_node("../Player/Upgrade_Factory")

@onready var menu = get_node("Menu")
@onready var inner_menu = get_node("Abilities")

var available_upgrades: Dictionary = {}

func _ready() -> void:
	skill_tree_1.connect("pressed", _on__pressed.bind("Utility"))
	skill_tree_2.connect("pressed", _on__pressed.bind("Utility"))
	skill_tree_3.connect("pressed", _on__pressed.bind("MainSkill"))
	skill_tree_4.connect("pressed", _on__pressed.bind("Ability"))
	
	skill_tree_4.visible = false


var is_paused: bool = false : 
	set = _set_paused,
	get = _get_paused


func _set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	
func _get_paused() -> bool:
	return is_paused


func on_level_up(coins: int) -> void:
	_set_paused(true)
	#Get available upgrades
	if coins >= 50:
		skill_tree_4.visible = true
	available_upgrades = upgrade_factory._export_tree(coins)


func _on__pressed(ab_name: String) -> void:
	menu.visible = false
	inner_menu.visible = true
	
	var choices: Array = upgrade_factory._get_random_upgrades(ab_name)
	
	option_1.text = choices[0].upgrade_name + "\n" + choices[0].upgrade_description 
	option_2.text = choices[1].upgrade_name + "\n" + choices[1].upgrade_description 
	option_3.text = choices[2].upgrade_name + "\n" + choices[2].upgrade_description 
	
	option_1.connect("pressed", _on_ability_choice.bind(choices[0]))
	option_2.connect("pressed", _on_ability_choice.bind(choices[1]))
	option_3.connect("pressed", _on_ability_choice.bind(choices[2]))


func _on_ability_choice(ability: Upgrade) -> void:
	upgrade_factory.apply_effect(ability)
	menu.visible = true
	inner_menu.visible = false
	option_1.disconnect("pressed", _on_ability_choice)
	option_2.disconnect("pressed", _on_ability_choice)
	option_3.disconnect("pressed", _on_ability_choice)
	_set_paused(false)



