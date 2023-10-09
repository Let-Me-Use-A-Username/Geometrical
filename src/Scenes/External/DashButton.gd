extends TouchScreenButton

@onready var player = get_parent().owner.owner as Player


func _process(delta: float) -> void:
	if is_pressed():
		var event = InputEventAction.new()
		event.action = "dash"
		event.pressed = true
		Input.parse_input_event(event)

func _handle_input(_event: InputEvent) -> void:
	if _event is InputEventScreenDrag:
		var trajectory = (_event.position - _event.relative).normalized()
		var current_dash_c = player.current_dash_count
		var dash_count = player.dash_count
