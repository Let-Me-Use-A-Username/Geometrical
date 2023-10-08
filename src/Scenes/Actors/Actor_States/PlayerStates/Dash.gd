extends PlayerState


signal touch_dashing(trajectory: Vector2)

@onready var player: Player = get_parent().owner as Player
@onready var dash_timer: Timer = get_parent().get_node('DashTransitionTimer')
var dash_time: float = 0.15

var touch_dash: bool = false
var dash_trajectory

var direction
var impulse

func _ready() -> void:
	super()
	dash_timer.set_wait_time(dash_time)
	dash_timer.set_one_shot(true)

func update(delta: float) -> void:
	pass

func get_direction() -> Vector2:
	return direction

func get_impulse() -> float:
	if impulse != null:
		return impulse
	return lerp(target_obj.speed * direction, target_obj.dash_speed * direction * target_speed_modifier, 0.8)


func physics_process(delta: float) -> void:
	if !touch_dash:
		direction = Input.get_vector("left", "right", "up", "down").normalized()
	else:
		direction = dash_trajectory
		
	impulse = lerp(target_obj.speed * direction, target_obj.dash_speed * direction * target_speed_modifier, 0.8)
	target_obj.set_velocity(impulse)
	
	if dash_timer.time_left == 0:
		state_machine._transition_to_state(self, state_machine.states.get('Idle'), {})


func enter_state(_msg: = {}) -> void:
	dash_timer.start()
	#enable dash bounds
	target_obj_dash_range.disabled = false
	#disable character bounds
	target_obj_bounds.disabled = true
	#disable colliding hitbox
	target_obj_collider.disabled = true
	
	if _msg.size() != 0:
		if _msg.has("target_speed_modifier"):
			target_speed_modifier = _msg.target_speed_modifier
		else:
			target_speed_modifier = 1
		
		if _msg.has("dash_trajectory"):
			dash_trajectory = _msg.dash_trajectory

func exit_state(_msg: = {}) -> void:
	#disable dash bounds
	target_obj_dash_range.disabled = true
	#enable character bounds
	target_obj_bounds.disabled = false
	#enable colliding hitbox
	target_obj_collider.disabled = false
