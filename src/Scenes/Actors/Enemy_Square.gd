class_name Enemy_Square extends Enemy


@onready var explotion_timer: Timer = get_node("ExplotionTimer")
@onready var state_machine = get_node('StateMachine')
@onready var explotion_radius = get_node("ExplotionRange")
var is_exploding: bool = false
var explotion_damage: float = 60

func _ready() -> void:
	self.add_to_group("Enemies")
	speed = Vector2(75, 75)
	health = 100
	damage = 20
	
	explotion_timer.set_wait_time(4)
	explotion_timer.set_one_shot(true)
	explotion_timer.connect('timeout', on_explotion_timeout)


func _physics_process(delta: float) -> void:
	if is_exploding:
		self.modulate.a = 0.5 if Engine.get_frames_drawn() % 2 == 0 else 1.0
	else:
		self.modulate.a = 1.0


func on_explotion_timeout() -> void:
	if explotion_radius.has_overlapping_bodies():
		for entity in explotion_radius.get_overlapping_bodies():
			if entity.is_in_group("Enemies") or entity.is_in_group("Player"):
				entity._on_remove_health(self, explotion_damage)
			_on_remove_health(self, 100)


func _on_explotion_range_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		explotion_timer.start()
		speed = Vector2(50, 50)
		is_exploding = true


func _on_explotion_range_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		explotion_timer.stop()
		explotion_timer.set_wait_time(2)
		speed = Vector2(75, 75)
		is_exploding = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.owner.name == 'Player':
		_on_remove_health(self, 100)
