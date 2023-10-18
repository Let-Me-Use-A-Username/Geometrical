extends PlayerState


@onready var player: Player = get_parent().owner as Player
@onready var knockback_timer: Timer = get_parent().get_node('KnockbackTimer')
var knockback_force = 180

var direction
var can_dash: bool = false
var stop_movement: bool = false

func _ready() -> void:
	super()
	knockback_timer.set_one_shot(true)
	knockback_timer.connect('timeout', on_undo_knockback)

func update(delta: float) -> void:
	pass

func get_direction() -> Vector2:
	return direction

func physics_process(delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down").normalized()
	if !stop_movement: 
		target_obj.set_velocity(target_obj.speed * direction)
	
	if target_obj.get_velocity() == Vector2.ZERO:
		state_machine._transition_to_state(self, state_machine.states.get('Idle'), {})
	
	if !stop_movement and can_dash:
		can_dash = false
		state_machine._transition_to_state(self, state_machine.states.get('Dash'), {'target_obj.speed_modifier': 5})

func enter_state(_msg: = {}) -> void:
	if _msg.size() != 0 and _msg.has('target_speed'):
		target_obj.speed = _msg.target_speed

func exit_state(_msg: = {}) -> void:
	pass

func on_dash() -> void:
	can_dash = true


func on_knockdown(origin:Node, disabled_time: float) -> void:
	var temp = (target_obj.global_position - origin.global_position).normalized() * knockback_force
	target_obj.set_velocity((target_obj.global_position - origin.global_position).normalized() * knockback_force)
	stop_movement = true
	knockback_timer.set_wait_time(disabled_time)
	knockback_timer.start()
	
func on_undo_knockback() -> void:
	stop_movement = false
	target_obj.set_velocity(Vector2.ZERO)
