extends Node
class_name State

@onready var state_machine = null

#player
var target_obj = null


func _ready() -> void:
	pass

func update(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass

func _handle_input(_event: InputEvent) -> void:
	pass

func enter_state(_msg: = {}) -> void:
	pass

func exit_state(_msg: = {}) -> void:
	pass
