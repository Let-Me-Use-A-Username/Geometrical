extends TouchScreenButton



func _process(delta: float) -> void:
	if is_pressed():
		var event = InputEventAction.new()
		event.action = "dash"
		event.pressed = true
		Input.parse_input_event(event)
