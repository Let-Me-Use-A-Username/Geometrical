extends Node2D


var player
var player_camera: Camera2D

#Ememy variables
var enemy_factory
var enemy_spawn_timer: Timer
var spawn_timer_offset: int
@export var wave_enemy_counter: int
@export var total_enemy_counter: int = 0
var spawn: bool

#Ability variables
@onready var freeze_timer: Timer
@onready var spaceshift_timer: Timer
@onready var camera_reset: Timer

#Game variables
@onready var _camera = get_node("GameCamera") as Camera2D
var window_size : Rect2
var location : Vector2

#Camera shake variables
@onready var noise = FastNoiseLite.new()
var noise_i = 0
var max_offset = Vector2(5, 2)
var max_roll = 0.1 
var shake: bool = false

#Audio
var audio_amplifier: Timer
var audio_emitted_times = 1


func _ready() -> void:
	spawn = true
	player = $Player
	player_camera = player.get_node("PlayerCamera") as Camera2D
	
	enemy_factory = get_node("Enemy_Factory")
	wave_enemy_counter = 1
	spawn_timer_offset = 1
	
	enemy_spawn_timer = get_node('SpawnTimer')
	enemy_spawn_timer.set_wait_time(spawn_timer_offset)
	enemy_spawn_timer.connect('timeout', _on_Timer_timeout)
	
	freeze_timer = get_node("FreezeTimer")
	spaceshift_timer = get_node("SpaceShiftTimer")
	camera_reset = get_node("CameraResetTimer")
	
	audio_amplifier = get_node("Audio_Amplifier")
	audio_amplifier.set_wait_time(1)
	audio_amplifier.one_shot = true
	
	player_camera.enabled = true
	player_camera.position = Vector2(0, 0)
	player_camera.make_current()
	player_camera.drag_horizontal_enabled = true
	player_camera.drag_vertical_enabled = true
	player_camera.drag_horizontal_offset = 0
	player_camera.drag_vertical_offset = 0
	player.get_node("PlayerCamera").align()
	
	noise.seed = randi()
	noise.frequency = 0.01
	noise.fractal_octaves = 5
	noise.noise_type = FastNoiseLite.TYPE_VALUE
	

func _on_Timer_timeout() -> void:
	var enemy_queue = enemy_factory.get_spawn_queue(total_enemy_counter, wave_enemy_counter)
	var coins = player.exp_counter
	
	spawn_enemies(enemy_queue)
	
	spawn_timer_offset += 1
	wave_enemy_counter = _get_wave_enemy_counter(coins)
	total_enemy_counter += enemy_queue.size()
	
	enemy_spawn_timer.wait_time = spawn_timer_offset


func _get_wave_enemy_counter(coins: int) -> int:
	if coins < 10:
		return spawn_timer_offset
	elif coins < 30:
		return spawn_timer_offset * 2
	elif coins < 50:
		return spawn_timer_offset * 3
	else:
		return spawn_timer_offset



func _process(delta: float) -> void:
	if spawn:
		enemy_spawn_timer.start()
		spawn = !spawn
	
	noise_i += 1
	if shake:
		_shacke_camera(2, 2)


#Function that handles the spawn of enemy nodes
func spawn_enemies(enemy_array : Array) -> void:
	randomize()
	var camera_position = player_camera.get_screen_center_position()
	var half = get_viewport_rect().size * 0.5
	var whole = half * 2
	var min_y = 0 - whole.y
	var min_x = 0 - whole.x
	window_size = Rect2(camera_position - half, camera_position + half)
	var max_y = window_size.end.y + whole.y
	var max_x = window_size.end.x + whole.x
	
	while enemy_array.size() != 0:
		var spawn_direction = randi_range(1, 4)

		match(spawn_direction):
			#Left x<0, y>0
			1:
				var rand_y = randf_range(0, max_y)
				location = Vector2(min_x, rand_y)
			#Up x>0, y<0
			2:
				var rand_x = randf_range(0, max_x)
				location = Vector2(rand_x, min_y)
			#Right x>0, y>0
			3:
				var rand_y = randf_range(0, max_y)
				location = Vector2(max_x, rand_y)
			#Down x>0, y>0
			4:
				var rand_x = randf_range(0, max_x)
				location = Vector2(rand_x, max_y)

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


func _on_Freeze_Timeout(actors: String) -> void:
	for entity in get_tree().get_nodes_in_group(actors):
		entity.set_physics_process(true)
		if entity.has_node("StateMachine"):
			entity.get_node("StateMachine").set_physics_process(true)
		if actors == "Enemies":
			for object in get_tree().get_nodes_in_group("Projectiles"):
				object.set_physics_process(true)


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
	shake = true


func _camera_reset() -> void:
	shake = false
	player_camera.rotation = 0
	player_camera.offset = Vector2.ZERO


func _shacke_camera(trauma: float, trauma_power: int) -> void:
	var amount = pow(trauma, trauma_power)
	player_camera.rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_i)
	player_camera.offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed, noise_i)
	player_camera.offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed, noise_i)

func _summon_rings(duration:float) -> void:
	var rings = player.get_node("Rings_Controller")
	rings.visible = true


func _gunslinger(duration: float) -> void:
	var gun = player.get_node("Gunslinger_Controller")
	gun.active = true


func _audio(audio_name: Resource):
	if AudioHandler:
		match audio_name.resource_name:
			"Enemy_Death":
				if audio_amplifier.time_left == 0:
					audio_amplifier.start()
					audio_emitted_times = 1
				
				if audio_amplifier.time_left != 0:
					audio_emitted_times += 1
				
				if audio_emitted_times <= 5:
					AudioHandler.play(1, self, audio_name, -10 + audio_emitted_times * 2, 0.2 * audio_emitted_times)
				elif audio_emitted_times <= 15:
					AudioHandler.play(1, self, audio_name, -15 + audio_emitted_times * 2, 0.05 * audio_emitted_times)
				else:
					AudioHandler.play(1, self, audio_name, -15, 0.02 * audio_emitted_times)
			"Gunslinger":
				AudioHandler.play(0, self, audio_name, -10, 0.5)
			"Gunslinger_bullet":
				AudioHandler.play(0, self, audio_name, 0, 0.1)
			"Level_Up":
				AudioHandler.play(0, self, audio_name, 0, 0.2)
			_:
				AudioHandler.play(0, self, audio_name)
				

func _effect(origin: Node, effect: String) -> void:
	if ParticleHandler:
		match effect:
			"Death":
				ParticleHandler._play_entity_efect(self, origin, true, "ff0303",load("res://assets/Particle_Effects/fire_01.png"), 0.1, 0.05)
			_:
				print("No effect")
				pass
