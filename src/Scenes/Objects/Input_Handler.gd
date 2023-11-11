class_name Input_Handler extends Node

enum OS_Type {KEYBOARD, TOUCH}

var _input_type
@onready var joystick = get_node("Background/Virtual Joystick") as VirtualJoystick
@onready var ui_debug = get_node("../UI_Debug")
@onready var player = owner as Player
@onready var _camera = get_node("../PlayerCamera") as Camera2D

@export var ui_position_offset: Vector2 = Vector2(230, 200)
@export var ui_scale_offset: Vector2 = Vector2(1.762, 1.698)
var fake_ui_scale: Vector2 = Vector2(1.45, 1.45)

var buttons = {}

func _ready() -> void:
	var dash_button = get_node("Background/DashButton")
	var viewport_rect = _camera.get_viewport_rect().size
	
	dash_button.position = viewport_rect - Vector2(ui_position_offset.x, ui_position_offset.y)
	dash_button.scale = ui_scale_offset
	
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
	var viewport_rect = _camera.get_viewport_rect().size
	var viewport_offset_x = 250
	var viewport_offset_y = 100
	
	#6.1 is to center it with the dash_button
	ability_button.position.x = dash_button.position.x + 6.1
	
	match player._player_abilities.size():
		1:
			ability_button.position.y = dash_button.position.y - viewport_offset_y * 1.5
		2:
			ability_button.position.y = dash_button.position.y - viewport_offset_y * 3
		3:
			ability_button.position.y = dash_button.position.y - viewport_offset_y * 4.5
	
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
	progress.scale = fake_ui_scale
	
	for ab in player._player_abilities:
		if ab.ability_name == ability.upgrade_name:
			buttons[progress] = ab


func _process(delta: float) -> void:
	for button in buttons:
		if button is TextureProgressBar:
			button.value = buttons[button].ability_cooldown_timer.time_left
