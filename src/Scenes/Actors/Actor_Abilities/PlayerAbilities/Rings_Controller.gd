extends Node2D


signal thunder_strike

@onready var ring_area = get_node("Rings_Area") as Area2D


func _ready() -> void:
	self.visible = false
	ring_area.collision_layer = 1
	ring_area.collision_mask = 2


func _process(delta: float) -> void:
	if self.visible:
		ring_area.monitorable = true
