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
	if time_passed > 60:# and wave_counter >= 20:
		for num in range(wave_counter / 4):
			spawn_queue.push_back(enemy_square)
		for num in range(wave_counter / 3):
			spawn_queue.push_back(enemy_triangle)
		while spawn_queue.size() != wave_counter:
			spawn_queue.push_back(enemy_circle)
		return spawn_queue
		
	if time_passed > 30:# and wave_counter >= 10:
		for num in range(wave_counter / 3):
			spawn_queue.push_back(enemy_triangle)
		while spawn_queue.size() != wave_counter:
			spawn_queue.push_back(enemy_circle)
		return spawn_queue
		
	if time_passed < 30:
		for num in range(wave_counter):
			spawn_queue.push_back(enemy_circle)
		return spawn_queue
	
	return spawn_queue
