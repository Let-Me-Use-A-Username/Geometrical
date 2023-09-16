extends Control

var is_paused: bool = false : 
	set = _set_paused,
	get = _get_paused

func _set_paused(value: bool) -> void:
	is_paused = value
	get_tree().paused = is_paused
	visible = is_paused
	
func _get_paused() -> bool:
	return is_paused

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		self.is_paused = !is_paused


func _on_resume_button_pressed() -> void:
	if _get_paused(): _set_paused(false)
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()
