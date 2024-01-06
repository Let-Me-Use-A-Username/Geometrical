extends Node


func _play_character_effect(callee: CharacterBody2D, p_material: Texture,p_texture_size_max: float, p_texture_size_min: float):
	var particle_handler = GPUParticles2D.new()
	callee.add_child(particle_handler)
	var _material = _prepare_material(Color("ffffff"), p_texture_size_max, p_texture_size_min)

	
	particle_handler.sub_emitter = particle_handler.get_path()
	particle_handler.process_material = _material
	particle_handler.texture = p_material
	particle_handler.local_coords = true
	particle_handler.emit_particle(callee.transform, callee.get_velocity(), Color("ffffff"), Color("ffffff"), 1)



func _play_entity_efect(handler: Node, origin: Node, one_shot: bool, color: Color, p_material: Texture,p_texture_size_max: float, p_texture_size_min: float):
	var particle_handler = GPUParticles2D.new()
	handler.add_child(particle_handler)
	var _material = _prepare_material(color, p_texture_size_max, p_texture_size_min)
	
	particle_handler.sub_emitter = particle_handler.get_path()
	particle_handler.process_material = _material
	particle_handler.texture = p_material
	particle_handler.position = origin.position
	particle_handler.one_shot = one_shot
	particle_handler.emitting = true



func _prepare_material(color: Color, p_texture_size_max: float, p_texture_size_min: float) -> ParticleProcessMaterial:
	var _material = ParticleProcessMaterial.new()
	_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	_material.scale_max = p_texture_size_max
	_material.scale_min = p_texture_size_min
	_material.gravity = Vector3.ZERO
	_material.PARTICLE_FLAG_DISABLE_Z
	_material.lifetime_randomness = 2
	_material.color = color
	return _material
