extends Node2D


var player
var player_camera
#Ememy variables
var enemy_factory
var enemy_spawn_timer: Timer
var timer: int
@export var enemy_wave_counter: int
@export var total_enemy_counter: int
var spawn: bool

#Ability variables
@onready var freeze_timer: Timer

#Game variables
@onready var _camera = get_node("GameCamera") as Camera2D
var window_size : Rect2
var location : Vector2

@export var isometric: bool = false

func _ready() -> void:
	spawn = true
	player = $Player
	player_camera = player.get_node("PlayerCamera") as Camera2D
	
	enemy_factory = get_node("Enemy_Factory")
	enemy_wave_counter = 3
	timer = 3
	
	enemy_spawn_timer = get_node('SpawnTimer')
	enemy_spawn_timer.set_wait_time(timer)
	enemy_spawn_timer.connect('timeout', _on_Timer_timeout)
	
	freeze_timer = get_node("FreezeTimer")
	freeze_timer.set_one_shot(true)
	
	if !isometric:
		_camera.enabled = true
		_camera.make_current()
	
		player_camera.enabled = false
	else:
		player_camera.enabled = true
		player_camera.position = Vector2(0, 0)
		player_camera.make_current()
		player_camera.drag_horizontal_enabled = true
		player_camera.drag_vertical_enabled = true
		player_camera.drag_horizontal_offset = 0
		player_camera.drag_vertical_offset = 0
		player.get_node("PlayerCamera").align()
	

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
	
	var _timer = get_node_or_null("SpaceShiftTimer")
	if _timer != null:
		var zoom = (2 * _timer.time_left) * delta + 1
		player_camera.set_zoom(Vector2(zoom, zoom))

#Function that handles the spawn of enemy nodes
func spawn_enemies(enemy_array : Array) -> void:
	randomize()
	var camera_position = player_camera.get_screen_center_position()
	var half = get_viewport_rect().size * 0.5
	window_size = Rect2(camera_position - half, camera_position + half)
	
	while enemy_array.size() != 0:
		var spawn_direction = randi_range(1, 4)
		location.x = randf_range(1, window_size.size.x)
		location.y = randf_range(1, window_size.size.y)

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
			spawn = false
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
	spawn = true


func _shockwave(origin: Node, damage: float) -> void:
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy._on_remove_health(origin, damage)


func _spaceshift(origin: Node, damage: float) -> void:
	_setup_player_camera()
	var timer = Timer.new()
	timer.name = "SpaceShiftTimer"
	add_child(timer)
	timer.set_wait_time(0.5)
	timer.set_one_shot(true)
	timer.connect("timeout", on_spaceshift_timeout.bind(origin, damage))
	timer.start()

func _setup_player_camera() -> void:
	_camera.position = lerp(_camera.position, player_camera.position, _camera.position /  player_camera.position)
	
	player_camera.position = Vector2(0,0)
	player_camera.position_smoothing_enabled = true
	player_camera.position_smoothing_speed = 10.0
	player_camera.enabled = true
	player_camera.make_current()
	
	_camera.enabled = false


func on_spaceshift_timeout(origin: Node, damage: float) -> void:
	if !isometric:
		var _timer = Timer.new()
		_timer.set_one_shot(true)
		_timer.set_wait_time(0.5)
		_timer.connect("timeout", camera_reset)
		add_child(_timer)
		_timer.start()
	
	_shockwave(origin, damage)
	_shacke_camera(1)


func camera_reset() -> void:
	_camera.enabled = true
	_camera.align()
	_camera.make_current()
	
	player_camera.enabled = false


func _shacke_camera(severity: int) -> void:
	var amount = pow(severity, 2)
	var max_roll = 0.1
	var max_offset = Vector2(12, 9)
	
	player_camera.rotation = max_roll * amount * randi_range(-1, 1)
	player_camera.offset.x = max_offset.x * amount * randi_range(-1, 1)
	player_camera.offset.y = max_offset.y * amount * randi_range(-1, 1)
	
	player_camera.set_zoom(Vector2(1, 1))
