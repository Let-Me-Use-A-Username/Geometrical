class_name Input_Handler extends Node

enum OS_Type {KEYBOARD, TOUCH}

var _input_type
@onready var joystick = get_node("Background/Virtual Joystick") as VirtualJoystick
@onready var ui_debug = get_node("../UI_Debug")
@onready var player = owner as Player

var buttons = {}

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
	joystick.visible = false
	joystick.process_mode = Node.PROCESS_MODE_DISABLED


func _get_Input_Type() -> Variant:
	if _input_type != null:
		return _input_type
	return OS_Type.KEYBOARD


func _on_button_created(ability: Upgrade) -> void:
	var background = get_node("Background")
	var dash_button = background.get_node("DashButton")
	
	var ability_button = TouchScreenButton.new()
	ability_button.position.x = dash_button.position.x + 20
	
	match player._player_abilities.size():
		1:
			ability_button.position.y = dash_button.position.y - 100
		2:
			ability_button.position.y = dash_button.position.y - 200
		3:
			ability_button.position.y = dash_button.position.y - 300
	
	background.add_child(ability_button)
			
	var progress = TextureProgressBar.new() as TextureProgressBar
	ability_button.add_child(progress)
	
	var icon_path = "res://assets/UI/Abilities/{str}-Pressed.png"
	progress.texture_progress = load(icon_path.format({"str":ability.upgrade_name}))
	progress.texture_under = load("res://assets/UI/Abilities/{str}.png".format({"str":ability.upgrade_name}))
	progress.fill_mode = 3
	progress.min_value = 0
	progress.max_value = int(ability.upgrade_effect.split("|")[1])
	progress.step = 0.2
	
	for ab in player._player_abilities:
		if ab.ability_name == ability.upgrade_name:
			buttons[progress] = ab


func _process(delta: float) -> void:
	for button in buttons:
		if button is TextureProgressBar:
			button.value = buttons[button].ability_timer.time_left
