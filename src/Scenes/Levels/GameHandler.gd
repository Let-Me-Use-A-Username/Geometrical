extends Node2D


var player
var player_camera: Camera2D
#Ememy variables
var enemy_factory
var enemy_spawn_timer: Timer
var spawn_offset: int
@export var enemy_wave_counter: int
@export var total_enemy_counter: int
var spawn: bool

#Ability variables
@onready var freeze_timer: Timer
@onready var spaceshift_timer: Timer
@onready var camera_reset: Timer

#Game variables
@onready var _camera = get_node("GameCamera") as Camera2D
var window_size : Rect2
var location : Vector2

@export var isometric: bool = false

@onready var noise = FastNoiseLite.new()


func _ready() -> void:
	spawn = true
	player = $Player
	player_camera = player.get_node("PlayerCamera") as Camera2D
	
	enemy_factory = get_node("Enemy_Factory")
	enemy_wave_counter = 3
	spawn_offset = 3
	
	enemy_spawn_timer = get_node('SpawnTimer')
	enemy_spawn_timer.set_wait_time(spawn_offset)
	enemy_spawn_timer.connect('timeout', _on_Timer_timeout)
	
	freeze_timer = get_node("FreezeTimer")
	spaceshift_timer = get_node("SpaceShiftTimer")
	camera_reset = get_node("CameraResetTimer")
	
	player_camera.enabled = true
	player_camera.position = Vector2(0, 0)
	player_camera.make_current()
	player_camera.drag_horizontal_enabled = true
	player_camera.drag_vertical_enabled = true
	player_camera.drag_horizontal_offset = 0
	player_camera.drag_vertical_offset = 0
	player.get_node("PlayerCamera").align()
	
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	

func _on_Timer_timeout() -> void:
	total_enemy_counter += 10
	
	var enemy_queue = enemy_factory.get_spawn_queue(total_enemy_counter, enemy_wave_counter)
	
	for i in range(enemy_wave_counter):
		spawn_enemies(enemy_queue)
	
	spawn_offset += 1
	enemy_wave_counter += 1
	
	enemy_spawn_timer.set_wait_time(spawn_offset)


func _process(delta: float) -> void:
	if spawn:
		enemy_spawn_timer.start()
		spawn = !spawn


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
				location.y = window_size.size.y + 200
			4:
				location.x = window_size.size.x + 200

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
	camera_reset.set_wait_time(2)
	if !camera_reset.is_connected("timeout", _camera_reset):
		spaceshift_timer.set_one_shot(true)
		camera_reset.connect("timeout", _camera_reset)
	camera_reset.start()
	
	spaceshift_timer.set_wait_time(0.5)
	if !spaceshift_timer.is_connected("timeout", on_spaceshift_timeout):
		spaceshift_timer.set_one_shot(true)
		spaceshift_timer.connect("timeout", on_spaceshift_timeout.bind(origin, damage))
	spaceshift_timer.start()

 
func on_spaceshift_timeout(origin: Node, damage: float) -> void:
	_shockwave(origin, damage)
	_shacke_camera()


func _camera_reset() -> void:
	player_camera.offset = Vector2.ZERO


func _shacke_camera() -> void:
	player_camera.offset = _get_noise(30, 90)


func _get_noise(speed: float, strength: float) -> Vector2:
	
	return Vector2(
		noise.get_noise_2d(1, 0.0) * strength,
		noise.get_noise_2d(100, 0.0) * strength
	)
