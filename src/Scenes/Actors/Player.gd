class_name Player extends Actor

signal died
signal level_up(coins: int)
signal dash

signal remove_health(origin: Node, damage: float)
signal knockdown(origin: Node, disabled_time: float)

signal freeze_enemy(actors: String, duration: float)
signal shockwave(origin: Node, damage: float)
signal spaceshift(origin: Node, damage: float)

enum States {IDLE, MOVE, DASH}
var _state = States.IDLE
@onready var state_machine = get_node('StateMachine')
@onready var input_handler = get_node('Input_Handler')
enum OS_Type {KEYBOARD, TOUCH}

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

var _player_abilities = []
var ring_damage: float = 50

func _ready() -> void:
	self.add_to_group("Player")
	get_node('DashArea/DashShape').disabled = true
	self.connect('remove_health', _on_remove_health)
	#State Signals
	knockdown.connect(state_machine.states['Move'].on_knockdown)
	knockdown.connect(get_node("Doppelganger").on_knockdown)
	dash.connect(state_machine.states['Move'].on_dash)
	#More State Signals
	level_up.connect(get_parent().get_node("LevelUp/LevelUpMenu").on_level_up)
	if !died.is_connected(get_parent().get_node("Quit/QuitMenu")._on_player_died):
		died.connect(get_parent().get_node("Quit/QuitMenu")._on_player_died)
	#Ability Signals
	freeze_enemy.connect(get_parent()._freeze_objects)
	shockwave.connect(get_parent()._shockwave)
	spaceshift.connect(state_machine.states['Dash'].on_spaceshift)
	#Properties
	_append_property_list()
	_update_property_list()
	
	_append_mainabilities_property_list()
	_update_mainabilities_property_list()
	#Timers
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
	if level_up_threshold.has(exp_counter) or level_up_threshold.back() <= exp_counter:
		emit_signal("level_up", exp_counter)
		level_up_threshold.pop_back()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('dash') and current_dash_count < dash_count:
		emit_signal('dash')
		dash_timer.start()
		dash_immune_timer.start()
		invurnerable = true
		current_dash_count += 1
	
	if _player_abilities.size() != 0:
		if _player_abilities.front() != null and event.is_action_pressed("primary_ability"):
			_activate_ability(_player_abilities.front())
		if _player_abilities.size() >= 2 and event.is_action_pressed("secondary_ability"):
			_activate_ability(_player_abilities[1])
		if _player_abilities.size() >= 3 and event.is_action_pressed("third_ability"):
			_activate_ability(_player_abilities.back())


func _activate_ability(ability: Ability) -> void:
	var _timer = ability.ability_cooldown_timer
	var _duration_timer = ability.ability_duration_timer
	
	if _timer not in self.get_children():
		add_child(_timer)
	if _duration_timer not in self.get_children():
		add_child(_duration_timer)
	
	if _duration_timer.is_connected("timeout", _on_ability_timer_timeout):
		_duration_timer.disconnect("timeout", _on_ability_timer_timeout)
		
	match ability.ability_name:
		#Makes player invurnerable and freezes all nodes
		"Timefreeze":
			if _timer.time_left == 0:
				invurnerable = true
				_duration_timer.connect("timeout", _on_ability_timer_timeout.bind(ability))
				emit_signal("freeze_enemy", "Enemies", ability.ability_duration)
				_timer.start()
		#Unlimited dashes
		"Supercharge":
			if _timer.time_left == 0:
				_duration_timer.connect("timeout", _on_ability_timer_timeout.bind(ability, dash_count))
				dash_count = 100000000
				_timer.start()
		"Spaceshift":
			if _timer.time_left == 0:
				current_dash_count = 0
				emit_signal("spaceshift", self, ability.ability_damage)
				_timer.start()
		"Superbeam":
			pass
		"Absorb":
			pass
		"Shield":
			pass
			
		_:
			print_debug("404: Upgrade not found: ", ability.upgrade_name)

func _on_ability_timer_timeout(ability: Ability, parameters: Variant) -> void:
	match ability.ability_name:
		"Timefreeze":
			invurnerable = false
		"Supercharge":
			dash_count = parameters
		"Spaceshift":
			pass
		"Superbeam":
			pass
		"Absorb":
			pass
		"Shield":
			pass


func _on_remove_health(origin: Node, damage: float) -> void:
	get_node("player").set_modulate("e74000") 
	_player_property_list["health"] = health - damage
	super(origin, damage)


func _despose_actor() -> void:
	get_tree().paused = true
	emit_signal("died")
	self.queue_free()


func on_dash_timer_timeout() -> void:
	if current_dash_count > 0:
		current_dash_count = 0


func _on_dasinv_timeout() -> void:
	invurnerable = false


func _on_invurnerable_signal() -> void:
	invurnerable = false
	get_node("player").set_modulate("ffffff") 


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
	#Appears to scale everything relatively, at the moment it doesn't bug anything out
	#but for future reference DO NOT SCALE THE AREAS, USE THE EXTENDS OR RADIUS AS SHOWN ABOVE
	self.scale = value

func _adjust_dash_size(value) -> void:
	var area = get_node("DashArea/DashShape") as CollisionShape2D
	area.scale = value
