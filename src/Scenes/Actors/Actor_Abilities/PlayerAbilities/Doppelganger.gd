extends Node


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
	var doppelganger_dash_area = get_node("../DashArea").duplicate()
	doppelganger.add_child(doppelganger_dash_area)
	
	
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


func _physics_process(delta: float) -> void:
	if copy:
		#if used ability
		if Input.is_action_pressed("primary_ability"):
			stack.push_front({"Action": "Ability", "_Ability" : player_abilities.front()})
		if Input.is_action_pressed("secondary_ability"):
			stack.push_front({"Action": "Ability", "_Ability" : player_abilities[1]})
		if Input.is_action_pressed("third_ability"):
			stack.push_front({"Action": "Ability", "_Ability" : player_abilities.back()})
		
		player_direction = Input.get_vector("left", "right", "up", "down").normalized()
	
		if Input.is_action_pressed("dash"):
			stack.push_front({"Action": "Dash", "direction": player_direction})
		else:
			stack.push_front({"Action": "Move", "direction": player_direction})
		
		if stack.size() > 0 and initialize:
			consume = true
			doppelganger.position = player.position
			initialize = false
		
	if consume:
		_consume_action(stack.pop_back())

func _consume_action(action: Dictionary) -> void:
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
				var dir = Vector2(action.direction)
				doppelganger.set_velocity(dir)
				doppelganger.move_and_slide()
				knockback_timer.start()
				consume = false
			"Ability":
				var ability = action._Ability as Ability
				#emit_signal(ability.ability_name)


func on_knockdown(origin:Node, disabled_time: float) -> void:
	if is_instance_valid(doppelganger):
		var vel = (player.global_position - origin.global_position).normalized() * 180
		stack.push_front({"Action": "Knockback", "direction": vel})
		knockback_timer.set_wait_time(disabled_time)


func on_undo_knockdown() -> void:
	consume = true


func _deactive_doppelganger() -> void:
	doppelganger.queue_free()
	copy = false
	consume = false
