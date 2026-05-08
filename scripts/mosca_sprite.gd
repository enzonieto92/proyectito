extends AnimatedSprite3D

@export var speed          : float = 2.0
@export var wander_radius  : float = 0.5
@export var hover_height   : float = 0.5
@export var hover_amplitude: float = 0.2
@export var turn_speed     : float = 2.5
@export var wander_rate    : float = 1.2

var _origin  : Vector3
var _vel     : Vector3 = Vector3.ZERO
var _time    : float   = 0.0
var _wander  : float   = 0.0

var _phase_a : float
var _freq_a  : float
var _freq_b  : float
var _amp_b   : float

func _ready() -> void:
	await get_tree().process_frame
	_origin = global_position
	_wander = randf() * TAU
	_vel    = Vector3(cos(_wander), 0, sin(_wander)) * speed

	_phase_a = randf() * TAU
	_freq_a  = randf_range(0.8, 1.8)
	_freq_b  = randf_range(2.0, 3.5)
	_amp_b   = randf_range(0.2, 0.5)

	play("volando")

func _process(delta: float) -> void:
	_time += delta

	_wander += randf_range(-wander_rate, wander_rate) * delta * TAU
	var wander_dir = Vector2(cos(_wander), sin(_wander))

	var flat    = Vector2(global_position.x, global_position.z)
	var to_home = Vector2(_origin.x, _origin.z) - flat
	var dist    = to_home.length()
	var pull    = to_home.normalized() * clamp((dist - wander_radius) / wander_radius, 0.0, 1.0)

	var dir     = (wander_dir + pull * 2.0).normalized()
	var desired = Vector3(dir.x, 0, dir.y) * speed

	_vel.x = lerp(_vel.x, desired.x, turn_speed * delta)
	_vel.z = lerp(_vel.z, desired.z, turn_speed * delta)

	global_position += Vector3(_vel.x, 0, _vel.z) * delta
	flip_h = _vel.x < 0.0

	var t        = _time + _phase_a
	var target_y = _origin.y + hover_height \
		+ sin(t * _freq_a) * hover_amplitude \
		+ sin(t * _freq_b) * hover_amplitude * _amp_b
	global_position.y = lerp(global_position.y, target_y, 3.0 * delta)
