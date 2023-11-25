extends PlayerState


signal _spaceshift_sound
signal _spaceshift(origin: Node, damage: float)
signal spaceshift_sound_revert

@onready var player: Player = get_parent().owner as Player
@onready var dash_timer: Timer = get_parent().get_node('DashTransitionTimer')
var dash_time: float = 0.15

var direction
var impulse

var spaceshift: bool = false
var spaceshift_source: Node
var spaceshift_damage: float

func _ready() -> void:
	super()
	dash_timer.set_wait_time(dash_time)
	dash_timer.set_one_shot(true)
	
	_spaceshift.connect(player.get_parent()._spaceshift)
	_spaceshift_sound.connect(player.get_node("Audio_Handler/AudioPlayer")._on_Spaceshift)
	spaceshift_sound_revert.connect(player.get_node("Audio_Handler/AudioPlayer")._on_Spaceshift_exit)

func update(delta: float) -> void:
	pass


func physics_process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down").normalized()
	var impulse
	
	if spaceshift:
		impulse = lerp((target_obj.speed * 2) * direction, (target_obj.dash_speed * 2) * direction * target_speed_modifier, 0.8)
		emit_signal("_spaceshift", spaceshift_source, spaceshift_damage)
		Engine.time_scale = 0.1
	else:
		impulse = lerp(target_obj.speed * direction, target_obj.dash_speed * direction * target_speed_modifier, 0.8)
	
	target_obj.set_velocity(impulse)
	
	if dash_timer.time_left == 0:
		state_machine._transition_to_state(self, state_machine.states.get('Idle'), {})


func on_spaceshift(origin: Node, damage: float) -> void:
	spaceshift = true
	spaceshift_source = origin
	spaceshift_damage = damage
	dash_timer.set_wait_time(dash_time * 1.5)
	emit_signal("_spaceshift_sound")


func enter_state(_msg: = {}) -> void:
	dash_timer.start()
	#enable dash bounds
	target_obj_dash_range.disabled = false
	#disable character bounds
	target_obj_bounds.disabled = true
	#disable colliding hitbox
	target_obj_collider.disabled = true
	
	if _msg.size() != 0:
		if _msg.has("target_speed_modifier"):
			target_speed_modifier = _msg.target_speed_modifier
		else:
			target_speed_modifier = 1

func exit_state(_msg: = {}) -> void:
	#disable dash bounds
	target_obj_dash_range.disabled = true
	#enable character bounds
	target_obj_bounds.disabled = false
	#enable colliding hitbox
	target_obj_collider.disabled = false
	
	if spaceshift:
		Engine.time_scale = 1
		spaceshift = false
		dash_timer.set_wait_time(dash_time)
		emit_signal("spaceshift_sound_revert")
