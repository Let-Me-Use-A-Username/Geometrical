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
			'-----------PLAYER STATS-----------'
		+ '\nMax Health: ' + str(player.get("max_health"))
		+ '\nHealth: ' + str(player.get("health")).erase(4, 10)
		+ '\nHealth Regen: ' + str(player.get("health_regen"))
		+ '\nSpeed: ' + str(player.get("speed"))
		+ '\nSize: ' + str(player.get("size"))
		+ '\nDamage: ' + str(player.get("damage"))
		+ '\n-----------DASH STATS-----------'
		+ '\nDash Total cooldown: ' + str(inv_timer.wait_time).erase(4, 10)
		+ '\nDash cd: ' + str(inv_timer.time_left).erase(4, 10)
		+ '\nDash speed: ' + str(player.get("dash_speed"))
		+ '\nTotal Dash Count: ' + str(player.dash_count)
		+ '\nCurrent dc: ' + str(player.current_dash_count)
		+ '\nInvurnerable: ' + str(player.get("invurnerable"))
		+ '\nDash Inv: ' + str(dash_timer.time_left).erase(4, 10))
		#+ '\n-----------GAME STATS-----------'
		#+ '\nCoins: ' + str(player.get("exp_counter"))
		
		healthbar.max_value = player.get("max_health")
		healthbar.value = player.get("health")
