extends Node2D


@onready var explotion_area = get_node("Explotion_Area") as Area2D


func _ready() -> void:
	explotion_area.monitoring = false


func _explotion(origin: Node, damage: float) -> void:
	explotion_area.collision_layer = 1
	explotion_area.collision_mask = 2
	explotion_area.monitoring = true
	for enemy in explotion_area.get_overlapping_bodies():
		if enemy.has_method("_on_remove_health"):
			enemy._on_remove_health(origin, damage)
