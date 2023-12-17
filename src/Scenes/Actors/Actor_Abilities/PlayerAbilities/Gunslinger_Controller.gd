extends Node2D


signal _bullet_sound

@onready var projectile = preload("res://src/Scenes/Actors/Actor_Abilities/PlayerAbilities/Player_Projectile.tscn")
@onready var gunslinger_area = get_node("Gunslinger_Area") as Area2D
@onready var player = get_parent()
@export var active = false

var shoot_cooldown: Timer

func _ready() -> void:
	gunslinger_area.monitoring = false
	shoot_cooldown = Timer.new()
	shoot_cooldown.set_wait_time(1.5)
	shoot_cooldown.connect("timeout", _shoot_projectile)
	add_child(shoot_cooldown)
	_bullet_sound.connect(get_node("../Audio_Handler")._gunslinger_bullet)
	

func _process(delta: float) -> void:
	if active:
		gunslinger_area.collision_layer = 1
		gunslinger_area.collision_mask = 2
		gunslinger_area.monitoring = true
		if shoot_cooldown.time_left == 0:
			shoot_cooldown.start()
		


func _shoot_projectile() -> void:
	if gunslinger_area.monitoring:
		for enemy in gunslinger_area.get_overlapping_bodies():
			if enemy != null and enemy.is_in_group("Enemies"):
				var bullet = projectile.instantiate()
				player.get_parent().call_deferred("add_child", bullet)
				bullet.global_position = player.global_position
				bullet.set_target(player.get_position().direction_to(enemy.global_position))
				shoot_cooldown.start()
				emit_signal("_bullet_sound")
