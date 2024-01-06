extends GPUParticles2D

@onready var player: Player = get_parent().owner 

func _ready() -> void:
	local_coords = true


func _process(delta: float) -> void:
	position = player.position
	var mat = process_material
