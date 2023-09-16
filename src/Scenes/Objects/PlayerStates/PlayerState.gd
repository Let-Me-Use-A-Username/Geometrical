class_name PlayerState extends State


#player bounds
var target_obj_bounds = null
#player colliding hitbox
var target_obj_collider = null
#player dash hitbox
var target_obj_dash_range = null

var target_speed_modifier: int


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
