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
var dash_count: int = 1
var current_dash_count: int = 0

var dash_immune_timer: Timer
var dash_immune_timer_offset: float = 0.2

var knockback_force = 30

var exp_counter = 0
var level_up_threshold = [100, 50, 30, 10, 5, 3, 1]

var _player_property_list = {}
var _player_mainskill_property_list = {}

func _ready() -> void:
	self.add_to_group("Player")
	get_node('DashArea/DashShape').disabled = true
	
	self.connect('remove_health', _on_remove_health)
	knockdown.connect(state_machine.states['Move'].on_knockdown)
	dash.connect(state_machine.states['Move'].on_dash)
	level_up.connect(get_parent().get_node("LevelUpMenu").on_level_up)
	
	_append_property_list()
	_update_property_list()
	
	_append_mainabilities_property_list()
	_update_mainabilities_property_list()
	
	dash_timer = get_node('DashTimer')
	dash_timer.set_wait_time(dash_timer_offset)
	dash_timer.set_one_shot(true)
	dash_timer.connect("timeout", on_dash_timer_timeout)
	
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
	if event.is_action_pressed("dash") and current_dash_count < dash_count:
		emit_signal("dash")
		dash_timer.start()
		dash_immune_timer.start()
		invurnerable = true
		current_dash_count += 1


func _on_remove_health(origin: Node, damage: float) -> void:
	self.set_modulate( Color8(180, 0, 0, 255) ) 
	_player_property_list["health"] = health - damage
	super(origin, damage)


func on_dash_timer_timeout() -> void:
	if current_dash_count > 0:
		current_dash_count = 0


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
		if (enemy.is_in_group("Enemies") or enemy.is_in_group("Projectiles")) and !invurnerable and dash_immune_timer.time_left == 0:
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
	
	
func _append_mainabilities_property_list() -> void:
	_player_mainskill_property_list["dash_size"] = get_node("DashArea/DashShape").get_scale()
	_player_mainskill_property_list["dash_speed"] = Vector2(800, 800)
	_player_mainskill_property_list["dash_count"] = 1
	_player_mainskill_property_list["dash_timer_offset"] = 2.0

func _update_mainabilities_property_list() -> void:
	dash_timer_offset = _player_mainskill_property_list["dash_timer_offset"]
	if dash_timer != null: dash_timer.set_wait_time(dash_timer_offset)
	dash_count = _player_mainskill_property_list["dash_count"]
	dash_speed = _player_mainskill_property_list["dash_speed"]


func _get(skill_name: StringName) -> Variant:
	if skill_name in _player_property_list:
		return [skill_name, _player_property_list.get(skill_name)]
	elif skill_name in _player_mainskill_property_list:
		return [skill_name, _player_mainskill_property_list.get(skill_name)]
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property in _player_property_list:
		#Special clauses for unique effects, when they affect more than the 
		#players properties. Size affects many colliders
		if property == "size":
			_adjust_size_parameters(value)
		
		_player_property_list[property] = value
		_update_property_list()
		return true
		
	elif property in _player_mainskill_property_list:
		if property == "dash_size":
			_adjust_dash_size(value)
		_player_mainskill_property_list[property] = value
		_update_mainabilities_property_list()
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

func _adjust_dash_size(value) -> void:
	var area = get_node("DashArea/DashShape") as CollisionShape2D
	area.scale = value
