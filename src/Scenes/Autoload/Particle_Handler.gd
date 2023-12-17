extends Node


func _play_particle_effect(callee: CharacterBody2D, p_material: Texture,p_texture_size_max: float, p_texture_size_min: float):
	var particle_handler = GPUParticles2D.new()
	callee.add_child(particle_handler)
	
	var _material = ParticleProcessMaterial.new()
	_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	_material.scale_max = p_texture_size_max
	_material.scale_min = p_texture_size_min
	_material.gravity = Vector3.ZERO
	_material.PARTICLE_FLAG_DISABLE_Z
	
	particle_handler.process_material = _material
	particle_handler.texture = p_material
	particle_handler.local_coords = false
	particle_handler.position = callee.position
	particle_handler.emit_particle(callee.transform, callee.get_velocity(), Color("ffffff"), Color("ffffff"), 1)
