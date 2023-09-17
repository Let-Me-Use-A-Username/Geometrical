extends Control


@onready var ability_1 = get_node("CenterContainer/HBoxContainer/#1")
@onready var ability_2 = get_node("CenterContainer/HBoxContainer/#2")
@onready var ability_3 = get_node("CenterContainer/HBoxContainer/#3")
@onready var ability_4 = get_node("CenterContainer/HBoxContainer/#4")

@onready var player = get_node("../Player")
@onready var upgrade_factory = get_node("../Player/Upgrade_Factory")

var available_upgrades: Array = []

func _ready() -> void:
	ability_1.connect("pressed", _on__pressed.bind(ability_1.text))
	ability_2.connect("pressed", _on__pressed.bind(ability_2.text))
	ability_3.connect("pressed", _on__pressed.bind(ability_3.text))
	ability_4.connect("pressed", _on__pressed.bind(ability_4.text))
	
	ability_4.visible = false


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
	if coins > 50:
		ability_4.visible = true
	available_upgrades = upgrade_factory._export_tree(coins)


func _on__pressed(name: String) -> void:
	print_debug("Button pressed ", name)
	_set_paused(false)
