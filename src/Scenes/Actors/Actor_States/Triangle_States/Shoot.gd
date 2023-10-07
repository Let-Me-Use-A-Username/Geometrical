extends State


const projectile = preload('res://src/Scenes/Actors/Actor_Abilities/TriangleAbilities/Triangle_projectile.tscn')
var shot: bool = false

var enemy
var enemy_direction

func _ready() -> void:
	super()

func update(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	if shot:
		var bullet = projectile.instantiate()
		get_parent().call_deferred("add_child", bullet)
		bullet.global_position = target_obj.global_position
		bullet.set_target(enemy_direction)
	
		state_machine._transition_to_state(self, state_machine.states.get('ShortWalk'), {"enemy_direction": enemy_direction})


func _handle_input(_event: InputEvent) -> void:
	pass

func enter_state(_msg: = {}) -> void:
	shot = true
	if _msg.has("enemy"):
		enemy = _msg.get("enemy")
	
	if _msg.has("direction"):
		enemy_direction = _msg.get("direction")

func exit_state(_msg: = {}) -> void:
	shot = false
