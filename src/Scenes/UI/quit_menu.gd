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
	
#Ignore wrong inputs
func _unhandled_input(event: InputEvent) -> void:
	pass

#Instantiate game
func _on_retry_button_pressed() -> void:
	if _get_paused(): _set_paused(false)
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_player_died() -> void:
	_set_paused(true)
