class_name PlayerStateMachine extends Node

signal transitioned

var active_state: PlayerState
var states: Dictionary = {}


func _ready() -> void:
	await('owner')
	for child in get_children():
		if child is PlayerState:
			child.state_machine = self
			child.target_obj = get_parent()
			child.target_obj_bounds = get_parent().get_node('PlayerBounds')
			child.target_obj_collider = get_parent().get_node('CollitionArea/CollisionShape')
			child.target_obj_dash_range = get_parent().get_node('DashArea/DashShape')
			states[child.name] =  child
	active_state = states.get('Idle')
	active_state.enter_state()

func _process(delta: float) -> void:
	active_state.update(delta)

func _physics_process(delta: float) -> void:
	active_state.physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	active_state._handle_input(event)

func _transition_to_state(origin: PlayerState, next_state: PlayerState, msg: Dictionary = {}):
	if next_state.name not in states:
		return
	active_state.exit_state()
	active_state = next_state
	active_state.enter_state(msg)
	emit_signal('transitioned', active_state.name)
	
