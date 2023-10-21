extends Node


signal freeze_enemy(actors: String, duration: float)
signal shockwave(origin: Node, damage: float)
signal blackhole
signal summon_rings(ring_damage: float)

@onready var player = get_parent() as Player
var state_machine
@onready var player_abilities: Array = player._player_abilities

var stack
var doppelganger: CharacterBody2D
var copy: bool = false
var consume: bool = false
var initialize: bool = false

var player_direction
var knockback_timer: Timer
var knockback: bool = false


func _ready() -> void:
	state_machine = get_node("../StateMachine")


func _initiate_doppelganger(duration: float) -> void:
	stack = []
	#Create doppelganger
	doppelganger = CharacterBody2D.new()
	#Add sprite
	var doppelganger_sprite = get_node("../player").duplicate()
	doppelganger.add_child(doppelganger_sprite)
	#Add area 2d for dash collition
	var doppelganger_dash_area = get_node("../DashArea").duplicate() as Area2D
	doppelganger.add_child(doppelganger_dash_area)
	doppelganger_dash_area.set_collision_layer_value(1, true)
	doppelganger_dash_area.set_collision_mask_value(2, true)
	doppelganger_dash_area.area_entered.connect(on_area_entered)
	
	var game_handler = player.get_parent()
	game_handler.add_child(doppelganger)
	copy = true
	initialize = true
	
	#death timer
	var _timer = Timer.new()
	doppelganger.add_child(_timer)
	_timer.set_wait_time(duration)
	_timer.set_one_shot(true)
	_timer.connect("timeout", _deactive_doppelganger)
	_timer.start()
	#knockback timer
	knockback_timer = Timer.new()
	doppelganger.add_child(knockback_timer)
	knockback_timer.set_one_shot(true)
	knockback_timer.connect("timeout", on_undo_knockdown)
	#abilities
	freeze_enemy.connect(player.owner._freeze_objects)
	shockwave.connect(player.owner._shockwave)


func _physics_process(delta: float) -> void:
	if copy:
		#if used ability
		if player_abilities.front() != null and Input.is_action_pressed("primary_ability"):
			stack.push_front({"Action": "Ability", "_Ability" : player_abilities.front()})
		if player_abilities.size() >= 2 and Input.is_action_pressed("secondary_ability"):
			stack.push_front({"Action": "Ability", "_Ability" : player_abilities[1]})
		if player_abilities.back() != null and Input.is_action_pressed("third_ability"):
			stack.push_front({"Action": "Ability", "_Ability" : player_abilities.back()})
		
		player_direction = Input.get_vector("left", "right", "up", "down").normalized()
	
		if Input.is_action_pressed("dash"):
			if player.current_dash_count < player.dash_count:
				stack.push_front({"Action": "Dash", "direction": player_direction})
		
		stack.push_front({"Action": "Move", "direction": player_direction})
		
		if stack.size() > 0 and initialize:
			consume = true
			doppelganger.position = player.position
			initialize = false
		
	if consume and stack.size() > 0:
		_consume_action(stack.pop_back())

func _consume_action(action: Dictionary) -> void:
	if knockback:
		doppelganger.position = player.position
	else:
		if is_instance_valid(doppelganger):
			match action.Action:
				"Move":
					var dir = Vector2(action.direction)
					var speed = player.speed
					doppelganger.set_velocity(dir * speed)
					doppelganger.move_and_slide()
				"Dash":
					var dir = Vector2(action.direction)
					var speed = player.dash_speed
					doppelganger.set_velocity(dir * speed)
					doppelganger.move_and_slide()
				"Knockback":
					knockback = true
					knockback_timer.start()
				"Ability":
					var ability = action._Ability as Ability
					_handle_ability(ability)


func _handle_ability(ability: Ability) -> void:
	match ability.ability_name:
		"Timefreeze":
			emit_signal("freeze_enemy", "Enemies", ability.ability_duration)
		"Shockwave":
			emit_signal("shockwave", self, ability.ability_damage)
		"BlackHole":
			pass
		"Rings":
			pass


func on_area_entered(area: Area2D) -> void:
	var entity = area.owner
	if (entity.is_in_group("Enemies") or entity.is_in_group("Projectiles")):
		print_debug("Destroying enemy as dopel")
		player.emit_signal("remove_health", entity, entity.get("damage"))


func on_knockdown(origin:Node, disabled_time: float) -> void:
	if is_instance_valid(doppelganger):
		stack.push_front({"Action": "Knockback"})
		knockback_timer.set_wait_time(disabled_time)


func on_undo_knockdown() -> void:
	knockback = false


func _deactive_doppelganger() -> void:
	doppelganger.queue_free()
	copy = false
	consume = false
