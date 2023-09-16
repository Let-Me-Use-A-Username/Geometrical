extends Node2D


var exp_value = 1

func _ready() -> void:
	if not is_in_group("Coins"):
		self.add_to_group("Coins")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		queue_free()
