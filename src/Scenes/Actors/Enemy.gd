class_name Enemy extends CharacterBody2D


#signals
signal death(sound_name: Resource)
signal _play_effect(origin: Node, effect: String)
#Objects
@onready var coin = preload("res://src/Scenes/Objects/coin.tscn")
@onready var death_sound = preload("res://assets/Sound/FX/Enemy_Death.wav")

var health: float
var health_regen: float
var damage: float
var abilities: = []
var speed: = Vector2()

var target_entity: Node
var move_direction


func _physics_process(delta: float) -> void:
	pass


func _on_remove_health(origin: Node, damage: float) -> void:
	health -= damage
	if health <= 0: _despose_actor()

func setTarget(node: Node) -> void:
	if node != null: 
		target_entity = node


func getTarget() -> Node:
	return target_entity


func _despose_actor() -> void:
	emit_signal("death", death_sound)
	randomize()
	if randi_range(1, 3) == 1:
		var obj = coin.instantiate()
		obj.position = self.position
		get_parent().call_deferred("add_child", obj)
	self.queue_free()
