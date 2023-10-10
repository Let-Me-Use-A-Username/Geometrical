class_name Upgrade_Handler extends Node


@onready var player = owner as Player
@onready var ui = get_parent().get_node("Input_Handler/Background")
var player_abilities 

var children_count 

func _ready() -> void:
	children_count = ui.get_child_count()

#Get children of the UI. If child count is higher, a new button was added
#We then connect the button to the below function
func _process(delta: float) -> void:
	if ui.get_child_count() > children_count:
		children_count = ui.get_child_count()
		var offset = 0
		for child in ui.get_children():
			if child is Button:
				if !child.is_connected("pressed", _on_button_press):
					child.connect("pressed", _on_button_press.bind(offset))
				offset += 1

#NOTE: Connected through editor
func _on_button_press(ability_name: int) -> void:
	player_abilities = player.get("_player_abilities")
	var event = InputEventAction.new()
	match ability_name:
		0:
			event.action = "primary_ability"
		1:
			event.action = "secondary_ability"
		2:
			event.action = "third_ability"
	
	event.pressed = true
	Input.parse_input_event(event)
