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

func activar(duracion: float = 5.0):
	_activo = true
	_tiempo = 0.0

	var tween = create_tween()
	tween.tween_method(_set_intensidad, 0.0, 1.0, 0.3)
	tween.tween_interval(duracion * 0.5)
	tween.tween_method(_set_intensidad, 1.0, 0.0, duracion * 0.5)
	tween.tween_callback(func(): _activo = false)

	var env = get_tree().get_first_node_in_group("world_environment")
	if env and env is WorldEnvironment:
		var tween_env = create_tween()
		tween_env.tween_method(
			func(v): env.environment.adjustment_saturation = v,
			1.0, 0.0, 0.3
		)
		tween_env.tween_interval(duracion * 0.4)
		tween_env.tween_method(
			func(v): env.environment.adjustment_saturation = v,
			0.0, 1.0, duracion * 0.3
		)

func _set_intensidad(v: float):
	material.set_shader_parameter("intensidad", v)
