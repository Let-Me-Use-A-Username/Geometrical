extends State


@onready var enemy_target: Node = get_parent().owner.target_entity
@onready var shoot_timer: Node = get_parent().owner.get_node("ShootCooldown")
var move_direction: Vector2
var distance: float

func _ready() -> void:
	super()

func update(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	if enemy_target != null: 
		move_direction = target_obj.global_position.direction_to(enemy_target.global_position)
		distance = target_obj.global_position.distance_to(enemy_target.global_position)
	
	if distance > 160:
		target_obj.set_velocity(target_obj.speed * move_direction * delta)
		var collision = target_obj.move_and_collide(target_obj.get_velocity())
		
	if target_obj.get_velocity() == Vector2.ZERO:
		state_machine._transition_to_state(self, state_machine.states.get('Idle'), {})


func _handle_input(_event: InputEvent) -> void:
	pass

func enter_state(_msg: = {}) -> void:
	pass

func exit_state(_msg: = {}) -> void:
	pass


func _on_enemy_triangle_shoot(area, direction) -> void:
	state_machine._transition_to_state(self, state_machine.states.get('Shoot'), {"enemy": area.owner, "direction": direction})
