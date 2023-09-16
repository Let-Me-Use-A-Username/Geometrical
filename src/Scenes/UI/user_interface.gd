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
	player = get_node_or_null('../Player')
	if player != null:
		label.set_text(' Dash cooldown: ' + str(inv_timer.time_left).erase(4, 10) 
		+ '\n Invurnerable: ' + str(player.get("invurnerable")) 
		+ '\n Dash Inv: ' + str(dash_timer.time_left).erase(4, 10))
		healthbar.value = player.get("health")
