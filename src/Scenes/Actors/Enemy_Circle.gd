class_name Enemy_Circle extends Enemy

func _ready() -> void:
	self.add_to_group("Enemies")
	death.connect(get_parent()._audio)
	_play_effect.connect(get_parent()._effect)
	death_sound.resource_name = "Enemy_Death"
	
	speed = Vector2(150, 150)
	health = 100
	damage = 20

func _physics_process(delta: float) -> void:
	if target_entity != null: 
		move_direction = get_position().direction_to(target_entity.global_position)
		set_velocity(speed * move_direction * delta)
		var collision = move_and_collide(get_velocity())

func _despose_actor() -> void:
	emit_signal("_play_effect", self, "Death")
	super()


func _on_hitbox_area_entered(area: Area2D) -> void:
	var obj = area.owner
	if (obj.is_in_group("Player") and area.name != "Gunslinger_Area") or obj.is_in_group("Player_Projectiles"):
		_on_remove_health(obj, 100)
