extends Control

signal paused_in
signal paused_out

func _ready() -> void:
	var parent = get_parent().owner
	var player = parent.get_node("Player")
	var audio_player = player.get_node("Audio_Handler/AudioPlayer")
	paused_in.connect(audio_player._on_paused)
	paused_out.connect(audio_player._on_exit_paused)

func _on_pause() -> void:
	emit_signal("paused_in")
	
	if !get_tree().paused:
		get_tree().paused = true
		visible = true


func _on_resume_button_pressed() -> void:
	emit_signal("paused_out")
	get_tree().paused = false
	visible = false
	

func _on_quit_button_pressed() -> void:
	get_tree().quit()

