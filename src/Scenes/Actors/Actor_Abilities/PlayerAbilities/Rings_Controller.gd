extends Node2D


signal thunder_strike

@onready var thunder_sprite = get_node("AnimatedSprite2D") as AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	thunder_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_rings_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		thunder_sprite.position
