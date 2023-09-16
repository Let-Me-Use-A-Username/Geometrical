extends Control


@onready var ability_1 = get_node("CenterContainer/HBoxContainer/#1")
@onready var ability_2 = get_node("CenterContainer/HBoxContainer/#2")
@onready var ability_3 = get_node("CenterContainer/HBoxContainer/#3")
@onready var ability_4 = get_node("CenterContainer/HBoxContainer/#4")


func _ready() -> void:
	ability_1.connect("pressed", _on__pressed.bind(ability_1.text))
	ability_2.connect("pressed", _on__pressed.bind(ability_2.text))
	ability_3.connect("pressed", _on__pressed.bind(ability_3.text))
	ability_4.connect("pressed", _on__pressed.bind(ability_4.text))


var is_paused: bool = false : 
	set = _set_paused,
	get = _get_paused


func _set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
	
func _get_paused() -> bool:
	return is_paused


func on_level_up() -> void:
	_set_paused(true)
	self.visible = true
	

func _on__pressed(name: String) -> void:
	print_debug("Button pressed ", name)
	_set_paused(false)
