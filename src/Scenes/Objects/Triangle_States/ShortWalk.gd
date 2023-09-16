extends State


@onready var shoot_timer: Node = get_parent().owner.get_node("ShootCooldown")
@onready var short_walk_timer: Timer = get_parent().get_node("ShortWalkTimer")
var move_direction: Vector2

func _ready() -> void:
	short_walk_timer.set_wait_time(2)
	short_walk_timer.set_one_shot(true)


func update(delta: float) -> void:
	pass


func physics_process(delta: float) -> void:
	target_obj.set_velocity(target_obj.speed * move_direction * delta)
	var collision = target_obj.move_and_collide(target_obj.get_velocity())
	
	if short_walk_timer.time_left == 0 and shoot_timer.time_left < 1:
		state_machine._transition_to_state(self, state_machine.states.get('Move'), {})
	

func short_walk(enemy_direction: Vector2) -> Vector2:
	var new_direction: Vector2
	if abs(enemy_direction.x) > abs(enemy_direction.y):
		new_direction.y = enemy_direction.y * -1
		if enemy_direction.x > 0:
			new_direction.x = enemy_direction.x * -1
		else:
			new_direction.x = enemy_direction.x * 1
	else:
		new_direction.x = enemy_direction.x * -1
		if enemy_direction.y > 0:
			new_direction.y = enemy_direction.y * -1
		else:
			new_direction.y = enemy_direction.y * 1
	
	return new_direction


func _handle_input(_event: InputEvent) -> void:
	pass


func enter_state(_msg: = {}) -> void:
	var enemy_direction
	if _msg.has("enemy_direction"):
		enemy_direction = _msg.get("enemy_direction")
	move_direction = short_walk(enemy_direction)
	short_walk_timer.start()


func exit_state(_msg: = {}) -> void:
	pass
