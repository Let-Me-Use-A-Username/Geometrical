extends CharacterBody2D
class_name Actor

var health: float
var health_regen: float
var damage: float
var abilities: = []
var speed: = Vector2()


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_remove_health(origin: Node, damage: float) -> void:
	health -= damage
	if health <= 0: _despose_actor()


func _despose_actor() -> void:
	self.queue_free()
