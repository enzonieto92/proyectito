extends ProgressBar

@onready var jugador: CharacterBody3D = get_tree().get_first_node_in_group("jugador")
var _tween: Tween = null

func _ready() -> void:
	max_value = jugador.STAMINA_MAX_REGEN
	value = max_value
	modulate.a = 0.0

func _process(_delta: float) -> void:
	value = jugador.stamina
	var porcentaje = jugador.stamina / jugador.STAMINA_MAX_REGEN
	if porcentaje < 0.3:
		_animar_alpha(1.0)
	else:
		_animar_alpha(0.0)

func _animar_alpha(objetivo: float) -> void:
	if modulate.a == objetivo:
		return
	if _tween and _tween.is_running():
		return
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", objetivo, 0.3)
	
