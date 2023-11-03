class_name Enemy_Triangle extends Enemy


signal shoot(area: Area2D, direction: Vector2)

@onready var shoot_timer: Timer = get_node('ShootCooldown')
@onready var state_machine = get_node('StateMachine')

var in_range = false

func _ready() -> void:
	self.add_to_group("Enemies")
	speed = Vector2(90, 90)
	health = 100
	damage = 20
	
	shoot_timer.set_wait_time(1)
	shoot_timer.set_one_shot(true)
	shoot_timer.connect('timeout', _on_shoot_timeout)


func _despose_actor() -> void:
	super()


func _on_shoot_timeout() -> void:
	in_range = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	var obj = area.owner
	if (obj.is_in_group("Player") and area.name != "Gunslinger_Area") or obj.is_in_group("Player_Projectiles"):
		_on_remove_health(obj, 100)


func _on_shoot_range_area_entered(area: Area2D) -> void:
	if area.owner.name == 'Player' and area.name != "Gunslinger_Area":
		in_range = true
		if shoot_timer.time_left == 0:
			emit_signal("shoot", area, get_position().direction_to(area.owner.global_position))
			shoot_timer.start()
