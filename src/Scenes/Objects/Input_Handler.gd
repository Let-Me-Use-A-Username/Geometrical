class_name Input_Handler extends Node

enum OS_Type {KEYBOARD, TOUCH}

var _input_type
@onready var joystick = get_node("Background/Virtual Joystick") as VirtualJoystick
@onready var ui_debug = get_node("../UI_Debug")
@onready var player = owner as Player

func _ready() -> void:
	match OS.get_name():
		"Android":
			print_debug("Mobile Phone detected...\n")
			_input_type = OS_Type.TOUCH
			_disable_debug_menu()
			
		"Windows", "UWP", "Linux", "Web":
			print_debug("Computer detected...\n")
			_input_type = OS_Type.KEYBOARD
			_disable_virtual_joystick()
			_disable_debug_menu()
			
		_:
			print_debug("Wasn't able to classify system...\n")
			print_debug("Proceeding with keyboard inputs\n")
			_input_type = OS_Type.KEYBOARD


func _disable_debug_menu() -> void:
	ui_debug.get_node("User_Interface/Info").visible = false
	ui_debug.get_node("User_Interface/Info").process_mode = Node.PROCESS_MODE_DISABLED


func _disable_virtual_joystick() -> void:
	self.visible = false
	self.process_mode = Node.PROCESS_MODE_DISABLED


func _get_Input_Type() -> Variant:
	if _input_type != null:
		return _input_type
	return OS_Type.KEYBOARD
