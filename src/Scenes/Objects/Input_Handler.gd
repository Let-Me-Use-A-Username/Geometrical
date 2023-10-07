extends Node

var _input_type: String
@onready var joystick = get_node("Virtual Joystick") as VirtualJoystick

func _init() -> void:
	match OS.get_name():
		"Android":
			print_debug("Mobile Phone detected...\n")
			_input_type = "Touch"
			
		"Windows", "UWP", "Linux", "Web":
			print_debug("Computer detected...\n")
			_input_type = "Keyboard"
			_disable_virtual_joystick()
			
		_:
			print_debug("Wasn't able to classify system...\n")
			print_debug("Proceeding with keyboard inputs\n")
			_input_type = "Keyboard"


func _disable_virtual_joystick() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED


func _get_Input_Type() -> String:
	if _input_type.length() > 1:
		return _input_type
	return "Keyboard"
