extends Node2D


@onready var player
@onready var enemy_factory

@onready var enemy_spawn_timer: Timer
var timer: int

@export var enemy_wave_counter: int
@export var total_enemy_counter: int
var spawn: bool

@onready var freeze_timer: Timer

#Window variables
@onready var window_size = get_window().size
@onready var _camera = get_node("GameCamera") as Camera2D
var location = Vector2()

func _ready() -> void:
	spawn = true
	player = $Player
	enemy_factory = get_node("Enemy_Factory")
	
	enemy_wave_counter = 3
	timer = 3
	
	enemy_spawn_timer = get_node('SpawnTimer')
	enemy_spawn_timer.set_wait_time(timer)
	enemy_spawn_timer.connect('timeout', _on_Timer_timeout)
	
	freeze_timer = get_node("FreezeTimer")
	freeze_timer.set_one_shot(true)
	

func _on_Timer_timeout() -> void:
	total_enemy_counter += 10
	
	var enemy_queue = enemy_factory.get_spawn_queue(total_enemy_counter, enemy_wave_counter)
	
	for i in range(enemy_wave_counter):
		spawn_enemies(enemy_queue)
	
	timer += 1
	enemy_wave_counter += 1
	
	enemy_spawn_timer.set_wait_time(timer)


func _process(delta: float) -> void:
	if spawn:
		enemy_spawn_timer.start()
		spawn = !spawn

#Function that handles the spawn of enemy nodes
func spawn_enemies(enemy_array : Array) -> void:
	randomize()
	
	while enemy_array.size() != 0:
		var spawn_direction = randi_range(1, 4)
		location.x = randf_range(1, window_size.x)
		location.y = randf_range(1, window_size.y)

		match(spawn_direction):
			1:
				location.x = -200
			2:
				location.y = -200
			3:
				location.y = 800
			4:
				location.x = 1300

		var _instance = enemy_array.pop_back().instantiate()

		_instance.position = location
		_instance.setTarget(player)
		add_child(_instance)


func _freeze_objects(code: String, duration: float) -> void:
	freeze_timer.set_wait_time(duration)
	match code:
		"Enemies":
			if !freeze_timer.is_connected("timeout", _on_Freeze_Timeout):
				freeze_timer.connect("timeout", _on_Freeze_Timeout.bind("Enemies"))
			for object in get_tree().get_nodes_in_group("Projectiles"):
				object.set_physics_process(false)
			for enemy in get_tree().get_nodes_in_group("Enemies"):
				enemy.set_physics_process(false)
				if enemy != null and enemy.has_node("StateMachine"):
					enemy.get_node("StateMachine").set_physics_process(false)
				freeze_timer.start()
			player.invurnerable = true
		_:
			player.invurnerable = true


func _on_Freeze_Timeout(actors: String) -> void:
	for entity in get_tree().get_nodes_in_group(actors):
		entity.set_physics_process(true)
		if entity.has_node("StateMachine"):
			entity.get_node("StateMachine").set_physics_process(true)
		if actors == "Enemies":
			for object in get_tree().get_nodes_in_group("Projectiles"):
				object.set_physics_process(true)
	player.invurnerable = false


func _shockwave(origin: Node, damage: float) -> void:
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy._on_remove_health(origin, damage)


func _spaceshift(origin: Node, damage: float) -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.set_wait_time(2)
	timer.set_one_shot(true)
	timer.connect("timeout", on_spaceshift_timeout.bind(origin, damage))
	timer.start()
	#_camera.set_zoom(Vector2(100, 100) * timer.time_left)

func on_spaceshift_timeout(origin: Node, damage: float) -> void:
	_shockwave(origin, damage)
