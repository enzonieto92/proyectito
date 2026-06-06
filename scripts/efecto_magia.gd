extends ColorRect

var _tiempo := 0.0
var _activo := false

func _ready():
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	material.set_shader_parameter("intensidad", 0.0)

func _process(delta):
	if not _activo:
		return
	_tiempo += delta
	material.set_shader_parameter("tiempo", _tiempo)

var _tween_principal: Tween = null
var _tween_env: Tween = null

func activar(duracion, _valor):
	# Cancelar tweens anteriores
	if _tween_principal and _tween_principal.is_running():
		_tween_principal.kill()
	if _tween_env and _tween_env.is_running():
		_tween_env.kill()

	_activo = true
	_tiempo = 0.0
	
	_tween_principal = create_tween()
	_tween_principal.tween_method(_set_intensidad, 0.0, 1.0, 0.3)
	_tween_principal.tween_interval(duracion * 0.5)
	_tween_principal.tween_method(_set_intensidad, 1.0, 0.0, duracion * 0.5)
	_tween_principal.tween_callback(func(): 
		_activo = false
)

	var env = get_tree().get_first_node_in_group("world_environment")
	if env and env is WorldEnvironment and _valor:
		_tween_env = create_tween()
		_tween_env.tween_method(
			func(v): env.environment.adjustment_saturation = v,
			1.0, 0.0, 0.3
		)
		_tween_env.tween_interval(duracion * 1.3)
		_tween_env.tween_method(
			func(v): env.environment.adjustment_saturation = v,
			0.0, 1.0, duracion * 1.3
		)
func _set_intensidad(v: float):
	material.set_shader_parameter("intensidad", v)
