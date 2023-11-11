extends TouchScreenButton


@onready var player = get_parent().get_parent().owner as Player
@onready var dash_timer = player.get_node("DashTimer")
var progress
var label

func _ready() -> void:
	progress = TextureProgressBar.new() as TextureProgressBar
	add_child(progress)
	progress.texture_progress = load("res://assets/UI/Abilities/Dash-Pressed-v2.png")
	progress.texture_under = self.texture_normal
	progress.fill_mode = 3
	progress.min_value = 0
	progress.max_value = player.dash_timer_offset
	progress.step = 0.2
	
	label = Label.new()
	add_child(label)
	label.position.y -= 24
	label.position.x += 16

func _process(delta: float) -> void:
	if label != null:
		label.text = str(player.current_dash_count) + " / " + str(player.dash_count)
	if progress != null:
		progress.value = dash_timer.time_left
	if is_pressed():
		var event = InputEventAction.new()
		event.action = "dash"
		event.pressed = true
		Input.parse_input_event(event)
