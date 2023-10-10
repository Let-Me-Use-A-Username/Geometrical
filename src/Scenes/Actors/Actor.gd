extends CharacterBody2D
class_name Actor

var max_health: float
var health: float
var health_regen: float
var damage: float
var speed: = Vector2()
var size: = Vector2()


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_remove_health(origin: Node, damage: float) -> void:
	health -= damage
	if health <= 0: _despose_actor()


func _despose_actor() -> void:
	self.queue_free()
