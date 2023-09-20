extends Control

var player: Node
var inv_timer: Timer
var dash_timer: Timer


@onready var label = $DashTimer
@onready var healthbar = $HealthBar

func _ready() -> void:
	inv_timer = get_node('../Player/DashTimer')
	dash_timer = get_node('../Player/DashImmuneTimer')


func _process(delta: float) -> void:
	player = get_node_or_null('../Player') as Player
	if player != null:
		label.set_text(
		'Max Health: ' + str(player.get("max_health"))
		+ '\nHealth: ' + str(player.get("health")).erase(4, 10)
		+ '\nHealth Regen: ' + str(player.get("health_regen"))
		+ '\nSpeed: ' + str(player.get("speed"))
		+ '\nSize: ' + str(player.get("size"))
		+ '\nDamage: ' + str(player.get("damage"))
		+ '\nCoins: ' + str(player.get("exp_counter"))
		+ '\nDash cooldown: ' + str(inv_timer.time_left).erase(4, 10)
		+ '\nInvurnerable: ' + str(player.get("invurnerable"))
		+ '\nDash Inv: ' + str(dash_timer.time_left).erase(4, 10))
		healthbar.max_value = player.get("max_health")
		healthbar.value = player.get("health")
