extends Node


@onready var player = get_parent() as Player
@onready var state_machine = get_parent().get_node("StateMachine") as State_Machine
@onready var player_abilities: Array = player._player_abilities

#Table that records the movement
var movement_table = {"direction": Vector2.ZERO, "dash": 0, "speed": 0}
#Table that records ability usage
var action_table = {"TimesFreezer": 0, "Supercharge": 0, "Shockwave": 0, "BlackHole": 0, "Rings": 0}
#Final table that the doppelganger will follow
var coppied_actions = {"action": "", "first_frame": 0, "speed_direction": []}
var coppied_table = []
var copy: bool = false


func _ready() -> void:
	set_physics_process(false)


func _initiate_doppelganger() -> void:
	set_physics_process(true)
	copy = true

func decomition_doppelgagner() -> void:
	set_physics_process(false)
	copy = false


func _unhandled_input(event: InputEvent) -> void:
	if copy and event.is_action_pressed("dash"):
		movement_table["dash"] = 1
		movement_table["speed"] = state_machine.states["Move"].get_impulse()
		movement_table["direction"] = state_machine.states["Move"].get_direction()
		
		coppied_actions["Action"] = "Dash"
		coppied_actions["first_frame"] = Engine.get_frames_drawn()
		coppied_actions["speed_direction"] = movement_table
		
		coppied_table.append(coppied_actions)
		
	if event.is_action_pressed("primary_ability"):
		pass
	if event.is_action_pressed("secondary_ability"):
		pass
	if event.is_action_pressed("third_ability"):
		pass


func _physics_process(delta: float) -> void:
	if copy:
		movement_table["direction"] = state_machine.states['Move'].get_direction()
		movement_table["speed"] = player.get_velocity()
		movement_table["dash"] = 0
		
		coppied_actions["action"] = "Move"
		coppied_actions["first_frame"] = Engine.get_frames_drawn()
		coppied_actions["speed_direction"] = movement_table
		
		coppied_table.append(coppied_actions)
	else:
		movement_table = {"left": 0, "right": 0, "up": 0, "down": 0, "Dash": 0, "Speed": 0}
		action_table = {"TimesFreezer": 0, "Supercharge": 0, "Shockwave": 0, "BlackHole": 0, "Rings": 0}
		coppied_actions = {"action": "", "FirstFrame": 0, "Speed": 0}
		coppied_table = {}
