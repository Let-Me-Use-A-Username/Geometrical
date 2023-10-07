extends State


func _ready() -> void:
	super()

func update(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	if target_obj.in_range == false:
		state_machine._transition_to_state(self, state_machine.states.get('Move'), {})

func _handle_input(_event: InputEvent) -> void:
	pass

func enter_state(_msg: = {}) -> void:
	pass

func exit_state(_msg: = {}) -> void:
	pass
