extends AudioStreamPlayer2D


@onready var _player = get_parent() as Player
#Sounds
@onready var Knockdown = preload("res://assets/Sound/FX/Collition.wav")

#Ability Sounds
@onready var Dash = preload("res://assets/Sound/FX/Dash_1.wav")
@onready var Supercharge_dash = preload("res://assets/Sound/FX/Supercharge_Per_Dash.wav")
@onready var Spaceshift = preload("res://assets/Sound/FX/Spaceshift.wav")
@onready var Timefreeze = preload("res://assets/Sound/FX/Timefreeze.wav")

var sounds = {}
var _supercharge_active


func _ready() -> void:
	sounds["Knockdown"] = Knockdown
	
	sounds["Dash"] = Dash
	sounds["Supercharge_dash"] = Dash
	sounds["Spaceshift"] = Spaceshift
	sounds["Timefreeze"] = Timefreeze
	
	for sound in sounds.values():
		sound.loop_mode = 0


func _on_knockdown(origin: Node, disabled_time: float) -> void:
	_play_sound("Knockdown")


func _on_dash() -> void:
	if _supercharge_active:
		_play_sound("Supercharge_dash")
	else:
		_play_sound("Dash")

func _on_Timefreeze(actors: String, duration: float) -> void:
	_play_sound("Timefreeze")

func _on_Supercharge(duration: float) -> void:
	_supercharge_active = true

func _on_Spaceshift(origin: Node, damage: float) -> void:
	_play_sound("Spaceshift")


func _play_sound(sound_name: String) -> void:
	self.stream = Dash
	play()
