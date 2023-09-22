class_name Player extends Actor

signal died
signal dash
signal level_up(coins: int)
signal remove_health(origin: Node, damage: float)
signal knockdown(origin: Node, disabled_time: float)

enum States {IDLE, MOVE, DASH}
var _state = States.IDLE
@onready var state_machine = get_node('StateMachine')

var invurnerable = false
var invurnerability_timer: Timer
var invurnerability_time = 1.5
var invurnerable_offset: = -0.15

var dash_speed: = Vector2(800, 800)
var dash_timer: Timer
var dash_timer_offset: float = 2.0

var dash_immune_timer: Timer
var dash_immune_timer_offset: float = 0.2

var knockback_force = 30

var exp_counter = 0
var level_up_threshold = [100, 50, 30, 10, 5, 3, 1]

var _player_property_list = {}

func _ready() -> void:
	self.add_to_group("Player")
	get_node('DashArea/DashShape').disabled = true
	
	self.connect('remove_health', _on_remove_health)
	knockdown.connect(state_machine.states['Move'].on_knockdown)
	dash.connect(state_machine.states['Move'].on_dash)
	level_up.connect(get_parent().get_node("LevelUpMenu").on_level_up)
	
	_append_property_list()
	_update_property_list()
	
	dash_timer = get_node('DashTimer')
	dash_timer.set_wait_time(dash_timer_offset)
	dash_timer.set_one_shot(true)
	
	dash_immune_timer = get_node('DashImmuneTimer')
	dash_immune_timer.set_wait_time(dash_immune_timer_offset)
	dash_immune_timer.set_one_shot(true)
	dash_immune_timer.connect('timeout', _on_dasinv_timeout)
	
	invurnerability_timer = get_node('Invurnerable')
	invurnerability_timer.set_wait_time(invurnerability_time)
	invurnerability_timer.set_one_shot(true)
	invurnerability_timer.connect('timeout', _on_invurnerable_signal)


func _process(delta: float) -> void:
	_state = state_machine.active_state.name
	if health != 100:
		health += health_regen
	if level_up_threshold.has(exp_counter):
		emit_signal("level_up", exp_counter)
		level_up_threshold.pop_back()


func _physics_process(delta: float) -> void:
	super(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and dash_timer.time_left == 0:
		emit_signal("dash")
		dash_timer.start()
		dash_immune_timer.start()
		invurnerable = true


func _on_remove_health(origin: Node, damage: float) -> void:
	self.set_modulate( Color8(180, 0, 0, 255) ) 
	_player_property_list["health"] = health - damage
	super(origin, damage)


func _on_dasinv_timeout() -> void:
	invurnerable = false


func _on_invurnerable_signal() -> void:
	invurnerable = false
	self.set_modulate( Color8(255, 255, 255, 255) ) 


func _on_collition_area_area_entered(area: Area2D) -> void:
	var enemy = area.owner
	if enemy.is_in_group("Coins"):
		exp_counter += 1
	else:
		if enemy.is_in_group("Enemies") and !invurnerable and dash_immune_timer.time_left == 0:
			emit_signal("remove_health", enemy, enemy.get("damage"))
			emit_signal("knockdown", enemy, 0.5)
			invurnerability_timer.start()
			invurnerable = true


func _append_property_list() -> void:
	_player_property_list["max_health"] = 100
	_player_property_list["health"] = 100
	_player_property_list["health_regen"] = 0.005
	_player_property_list["damage"] = 100
	_player_property_list["speed"] = Vector2(300, 300)
	_player_property_list["size"] = transform.get_scale()
	


func _update_property_list() -> void:
	max_health = _player_property_list["max_health"]
	health = _player_property_list["health"]
	health_regen = _player_property_list["health_regen"]
	damage = _player_property_list["damage"]
	speed =  _player_property_list["speed"]
	size = _player_property_list["size"]


func _get(name: StringName) -> Variant:
	if name in _player_property_list:
		return [name, _player_property_list.get(name)]
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property in _player_property_list:
		#Special clauses for unique effects, like size affecting the sprite
		if property == "size":
			_adjust_size_parameters(value)
		
		_player_property_list[property] = value
		_update_property_list()
		return true
	return false


func _adjust_size_parameters(value: Variant) -> void:
	#var sprite = get_node("player") as Sprite2D
	#var bounds = get_node("PlayerBounds") as CollisionShape2D
	#var collition_area = get_node("CollitionArea/CollisionShape") as CollisionShape2D
	#var dash_area = get_node("DashArea/DashShape") as CollisionShape2D
	
	#sprite.scale =  Vector2(value.x - 0.85, value.y - 0.85)
	#bounds.shape.set_radius(value.x * 10)
	#collition_area.shape.set_radius(value.x * 10)
	#dash_area.shape.set_radius(value.x * 10)
	
	#Appears to scale everything relatively, at the moment it doesn't bug anything out
	#but for future reference DO NOT SCALE THE AREAS, USE THE EXTENDS OR RADIUS AS SHOWN ABOVE
	self.scale = value
	
