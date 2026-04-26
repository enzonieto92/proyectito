extends AnimatedSprite3D
# ── Configuración ──────────────────────────────────────────
@export var speed          : float = 3.0
@export var wander_radius  : float = 0.3
@export var hover_height   : float = 0.0
@export var hover_amplitude: float = 0.15
@export var dart_chance    : float = 0.3
@export var min_idle_time  : float = 0.4
@export var max_idle_time  : float = 1.8
@export var steering_speed : float = 4.0   # qué tan rápido gira hacia el destino (menor = más curvo)

# ── Estado interno ─────────────────────────────────────────
var _origin        : Vector3
var _target        : Vector3
var _idle_timer    : float   = 0.0
var _is_darting    : bool    = false
var _velocity      : Vector3 = Vector3.ZERO   # velocidad actual interpolada

# Target Y independiente
var _target_y      : float
var _target_y_timer: float = 0.0
var _vertical_spd  : float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	_origin   = global_position
	_target_y = _origin.y
	_pick_new_target()
	_pick_new_target_y()
	play("volando")

func _pick_new_target_y() -> void:
	_target_y       = _origin.y + hover_height + randf_range(-hover_amplitude, hover_amplitude) * 3.0
	_vertical_spd   = randf_range(0.3, 1.4)
	_target_y_timer = randf_range(0.3, 1.2)

func _process(delta: float) -> void:
	# ── Movimiento vertical errático interpolado ──
	_target_y_timer -= delta
	if _target_y_timer <= 0.0:
		_pick_new_target_y()
	var target_vy = (_target_y - global_position.y) * _vertical_spd
	_velocity.y = lerp(_velocity.y, target_vy, steering_speed * delta)
	global_position.y += _velocity.y * delta

	# ── Movimiento horizontal ──
	if _is_darting:
		_move_toward_target(delta)
	else:
		_idle_timer -= delta
		if _idle_timer <= 0.0:
			_pick_new_target()

func _move_toward_target(delta: float) -> void:
	var flat_pos    = Vector3(global_position.x, 0.0, global_position.z)
	var flat_target = Vector3(_target.x,         0.0, _target.z)
	var dist        = flat_pos.distance_to(flat_target)

	if dist < 0.08:
		_is_darting = false
		_idle_timer = randf_range(min_idle_time, max_idle_time)
		_velocity.x = 0.0
		_velocity.z = 0.0
		return

	# Dirección deseada con posible tirón brusco
	var desired_spd = speed * (2.0 if randf() < dart_chance * delta else 1.0)
	var desired_vel = (flat_target - flat_pos).normalized() * desired_spd

	# Interpolar velocidad actual → deseada (aquí está la curva)
	_velocity.x = lerp(_velocity.x, desired_vel.x, steering_speed * delta)
	_velocity.z = lerp(_velocity.z, desired_vel.z, steering_speed * delta)

	global_position += Vector3(_velocity.x, 0.0, _velocity.z) * delta
	flip_h = _velocity.x < 0.0

func _pick_new_target() -> void:
	var angle  = randf() * TAU
	var radius = randf_range(0.1, wander_radius)
	_target = Vector3(
		_origin.x + cos(angle) * radius,
		0.0,
		_origin.z + sin(angle) * radius
	)
	_is_darting = true
