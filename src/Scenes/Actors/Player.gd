class_name Player extends Actor

signal died
signal level_up(coins: int)
signal dash

signal remove_health(origin: Node, damage: float)
signal knockdown(origin: Node, disabled_time: float)

signal freeze_enemy(actors: String, duration: float)
signal shockwave(origin: Node, damage: float)
signal doppelganger(duration: float)
signal blackhole
signal summon_rings(ring_damage: float)

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
	dash.connect(state_machine.states['Move'].on_dash)
	#More State Signals
	level_up.connect(get_parent().get_node("LevelUp/LevelUpMenu").on_level_up)
	if !died.is_connected(get_parent().get_node("Quit/QuitMenu")._on_player_died):
		died.connect(get_parent().get_node("Quit/QuitMenu")._on_player_died)
	#Ability Signals
	freeze_enemy.connect(get_parent()._freeze_objects)
	shockwave.connect(get_parent()._shockwave)
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
	if level_up_threshold.has(exp_counter):
		emit_signal("level_up", exp_counter)
		level_up_threshold.pop_back()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('dash') and current_dash_count < dash_count:
		emit_signal('dash')
		dash_timer.start()
		dash_immune_timer.start()
		invurnerable = true
		current_dash_count += 1
	
	if event.is_action_pressed("primary_ability"):
		_activate_ability(_player_abilities.front())
	if event.is_action_pressed("secondary_ability"):
		_activate_ability(_player_abilities[1])
	if event.is_action_pressed("third_ability"):
		_activate_ability(_player_abilities.back())


func _activate_ability(ability: Ability) -> void:
	var temp_timer = Timer.new()
	add_child(temp_timer)
	temp_timer.set_one_shot(false)
	temp_timer.set_wait_time(ability.ability_cooldown)
	print("creating timer")
	match ability.ability_name:
		"Timefreeze":
			emit_signal("freeze_enemy", "Enemies", ability.ability_duration)
		"Supercharge":
			temp_timer.connect("timeout", _on_ability_timer_timeout.bind( "Supercharge", dash_count))
			dash_count = 100000000
			temp_timer.start()
		"Shockwave":
			emit_signal("shockwave", self, ability.ability_damage)
		"Doppelganger":
			emit_signal("doppelganger", ability.ability_duration)
			temp_timer.start()
			#when the ability starts, a stack captures the players movement and then repeats
			#it later
		"BlackHole":
			#Summon a black hole somewhere randomly 
			emit_signal("blackhole")
		"Rings":
			emit_signal("summon_rings", ring_damage)
		_:
			print_debug("404: Upgrade not found: ", ability.upgrade_name)


func _on_ability_timer_timeout(ability_name: String, parameters: Variant) -> void:\
	match ability_name:
		"Timefreeze":
			pass
		"Supercharge":
			dash_count = parameters
		"Shockwave":
			pass
		"Doppelganger":
			pass
		"BlackHole":
			pass
		"Rings":
			pass


func _on_remove_health(origin: Node, damage: float) -> void:
	get_node("player").set_modulate( Color8(180, 0, 0, 255) ) 
	_player_property_list["health"] = health - damage
	super(origin, damage)


func _despose_actor() -> void:
	emit_signal("died")
	self.queue_free()


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
	#Appears to scale everything relatively, at the moment it doesn't bug anything out
	#but for future reference DO NOT SCALE THE AREAS, USE THE EXTENDS OR RADIUS AS SHOWN ABOVE
	self.scale = value

func _adjust_dash_size(value) -> void:
	var area = get_node("DashArea/DashShape") as CollisionShape2D
	area.scale = value
