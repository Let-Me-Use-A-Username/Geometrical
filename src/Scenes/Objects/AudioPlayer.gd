extends AudioStreamPlayer2D


@onready var _player = get_parent().get_parent() as Player
#Sounds
@onready var Knockdown = preload("res://assets/Sound/FX/Collition.wav")
@onready var Level_Up = preload("res://assets/Sound/FX/Level_Up.wav")
@onready var Died = preload("res://assets/Sound/FX/Died.wav")
@onready var Paused_In = preload("res://assets/Sound/FX/Pause_In.wav")
@onready var Paused_Out = preload("res://assets/Sound/FX/Pause_Out.wav")
@onready var Coin_Pickup = preload("res://assets/Sound/FX/Coin_Pickup.wav")

#Ability Sounds
@onready var Dash = preload("res://assets/Sound/FX/Dash_1.wav")
@onready var Supercharge_dash = preload("res://assets/Sound/FX/Supercharge_Per_Dash.wav")
@onready var Spaceshift = preload("res://assets/Sound/FX/Spaceshift.wav")
@onready var Timefreeze = preload("res://assets/Sound/FX/Timefreeze.wav")
@onready var Rings = preload("res://assets/Sound/FX/Rings.wav")
@onready var Explotion = preload("res://assets/Sound/FX/Explotion.wav")
@onready var Gunslinger = preload("res://assets/Sound/FX/Gunslinger.wav")

#Additional ability Sounds
@onready var Gunslinger_bullet = preload("res://assets/Sound/FX/Gunslinger_Bullet.wav")

var sounds = {}
var _supercharge_active = false
var _spaceshift_active = false


func _ready() -> void:
	sounds["Knockdown"] = Knockdown
	sounds["Level_Up"] = Level_Up
	sounds["Died"] = Died
	sounds["Paused_In"] = Paused_In
	sounds["Paused_Out"] = Paused_Out
	sounds["Coin_Pickup"] = Coin_Pickup
	
	sounds["Dash"] = Dash
	sounds["Supercharge_dash"] = Dash
	sounds["Spaceshift"] = Spaceshift
	sounds["Timefreeze"] = Timefreeze
	sounds["Rings"] = Rings
	sounds["Gunslinger"] = Gunslinger
	sounds["Explotion"] = Explotion
	
	sounds["Gunslinger_bullet"] = Gunslinger_bullet
	
	for sound in sounds.values():
		sound.loop_mode = 0

#State sounds
func _on_knockdown(origin: Node, disabled_time: float) -> void:
	_play_sound(Knockdown)

func _on_level_up(coins: int) -> void:
	_play_sound(Level_Up)

func _on_player_died() -> void:
	_play_sound(Died)

func _on_coin_pickup() -> void:
	_play_sound(Coin_Pickup)

func _on_paused() -> void:
	_play_sound(Paused_In)

func _on_exit_paused() -> void:
	_play_sound(Paused_Out)

#Ability sounds
func _on_dash() -> void:
	if _supercharge_active and !_spaceshift_active:
		_play_sound(Supercharge_dash)
	elif !_supercharge_active and _spaceshift_active:
		_play_sound(Spaceshift)
	else:
		_play_sound(Dash)

func _on_Timefreeze(actors: String, duration: float) -> void:
	_play_sound(Timefreeze)

func _on_Supercharge(duration: float) -> void:
	_supercharge_active = true
	_spaceshift_active = false

func _on_Supercharge_exit() -> void:
	_supercharge_active = false

func _on_Spaceshift() -> void:
	_spaceshift_active = true
	_supercharge_active = false

func _on_Spaceshift_exit() -> void:
	_spaceshift_active = false

func _on_Rings(duration: float) -> void:
	_play_sound(Rings)

func _on_Gunslinger(duration: float) -> void:
	_play_sound(Gunslinger)

func _gunslinger_bullet() -> void:
	_play_sound(Gunslinger_bullet)

func _on_Explotion(origin: Node, damage: float) -> void:
	_play_sound(Explotion)



func _play_sound(sound_name: AudioStream) -> void:
	if sound_name == Spaceshift:
		play()
		_add_pause(0.9)
		
	self.stream = sound_name
	play()


func _add_pause(time: float):
	await get_tree().create_timer(time, false, false, true).timeout
	stop()
	#FIXME! When the player resumes, it starts from the beggining. So i should save the point and continue
	#from there
	await get_tree().create_timer(time/2, false, false, true).timeout
	play()
