extends Node


var enemy_circle
var enemy_triangle
var enemy_square

var spawn_queue = []

var time_passed


func _ready() -> void:
	enemy_circle = preload("res://src/Scenes/Actors/Enemy_Circle.tscn")
	enemy_triangle = preload("res://src/Scenes/Actors/Enemy_Triangle.tscn")
	enemy_square = preload("res://src/Scenes/Actors/Enemy_Square.tscn")


func _process(delta: float) -> void:
	time_passed = Time.get_ticks_msec() / 600



func get_spawn_queue(total_enemies: int, wave_counter: int) -> Array:
	#If enemies are less than 32 spawn only circles
	if wave_counter < 32:
		for num in range(wave_counter):
			spawn_queue.push_back(enemy_circle)
		return spawn_queue

	#If enemies are less than 75 spawn only circles
	#1/10 are triangles
	if wave_counter < 75:
		var spawn_num = wave_counter / 10
		if (abs(ceil(spawn_num) - spawn_num)) < (abs(floor(spawn_num) - spawn_num)):
			spawn_num = ceil(wave_counter / 10)
		else:
			spawn_num = floor(wave_counter / 10)
			
		for num in spawn_num:
			spawn_queue.push_back(enemy_triangle)
		while spawn_queue.size() != wave_counter:
			spawn_queue.push_back(enemy_circle)
		return spawn_queue
		
	#If enemies are less than 110 spawn only circles
	#1/10 are squares
	#1/8 are triangles
	if wave_counter < 110 or wave_counter > 110:
		var spawn_num_square = wave_counter / 10
		if (abs(ceil(spawn_num_square) - spawn_num_square)) < (abs(floor(spawn_num_square) - spawn_num_square)):
			spawn_num_square = ceil(wave_counter / 10)
		else:
			spawn_num_square = floor(wave_counter / 10)
			
		var spawn_num_triangle = wave_counter / 8
		if (abs(ceil(spawn_num_triangle) - spawn_num_triangle)) < (abs(floor(spawn_num_triangle) - spawn_num_triangle)):
			spawn_num_triangle = ceil(wave_counter / 10)
		else:
			spawn_num_triangle = floor(wave_counter / 10)
			
		for num in spawn_num_square:
			spawn_queue.push_back(enemy_square)
		for num in spawn_num_triangle:
			spawn_queue.push_back(enemy_triangle)
		while spawn_queue.size() != wave_counter:
			spawn_queue.push_back(enemy_circle)
		return spawn_queue
	
	return spawn_queue
