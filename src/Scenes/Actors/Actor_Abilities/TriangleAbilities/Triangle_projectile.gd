extends CharacterBody2D


@onready var timer: Timer = get_node("FreeTimer")
@onready var deathtimer: Timer = get_node("DeathTimer")

var target
var damage
var speed

func _init() -> void:
	self.add_to_group("Projectiles")
	damage = 15
	speed = Vector2(0.5, 0.5)


func _ready() -> void:
	timer.set_wait_time(0.2)
	timer.set_one_shot(true)
	timer.connect('timeout', on_timer_timeout)
	
	deathtimer.set_wait_time(20)
	timer.set_one_shot(true)
	deathtimer.connect('timeout', on_timer_timeout)
	deathtimer.start()
	

func _physics_process(delta: float) -> void:
	move_and_collide(get_velocity())


func set_target(coordinates: Vector2) -> void:
	target = coordinates
	set_velocity(target * speed)
	look_at(target)


func on_timer_timeout() -> void:
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var entity = area.owner
	if entity.name == 'Player':
		timer.start()
