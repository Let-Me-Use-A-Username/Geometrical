extends GPUParticles2D

@onready var player = get_parent().get_parent().owner
@onready var ray = get_parent().get_node("ReverseDirection")

func _ready() -> void:
	#local_coords = true
	pass


func _process(delta: float) -> void:
	var mat = process_material
	var dir = Input.get_vector("left", "right", "up", "down").normalized()
	mat.direction = -Vector3(dir.x, dir.y, 0)
	var angle = dir.x - dir.y
