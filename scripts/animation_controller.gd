extends Node

@onready var anim_tree: AnimationTree = $"../AnimationTree"
@onready var movimiento_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/movimiento/playback"]
@onready var ataque_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/ataque/playback"]
@onready var player: CharacterBody3D = $".."
@onready var timer_bloqueo: Timer = Timer.new()

var defendiendo: bool = false
var esperando_soltar := false
var animaciones_arma = ["atacar", "atacar_horizontal"]
var animacion_en_curso: bool = false
var blend_objetivo: float = 0.0
var estaba_bloqueando: bool = false
const BLEND_VELOCIDAD: float = 5.0
const TIEMPO_ACTIVACION_BLOQUEO: float = 0.2  # ajustá este valor

func _ready():
	anim_tree.active = true
	anim_tree["parameters/Add2/add_amount"] = 0.0
	movimiento_sm.travel("idle")
	add_child(timer_bloqueo)
	timer_bloqueo.one_shot = true
	timer_bloqueo.timeout.connect(_on_bloqueo_listo)

func _on_bloqueo_listo():
	if defendiendo:
		player.activar_bloqueo()

func resetear_estado() -> void:
	animacion_en_curso = false
	defendiendo = false
	esperando_soltar = false
	estaba_bloqueando = false
	player.puede_correr = true
	blend_objetivo = 0.0
	timer_bloqueo.stop()
	player.desactivar_bloqueo()
	movimiento_sm.travel("idle")

func _ataque_termino():
	animacion_en_curso = false
	player.puede_correr = true
	blend_objetivo = 0.0
	if defendiendo:
		_iniciar_bloqueo()
	elif Input.is_action_pressed("atacar") and is_instance_valid(player.arma):
		play_random_animation()

func _actualizar_movimiento():
	if player.moving:
		if player.corriendo and player.puede_correr:
			movimiento_sm.travel("correr")
		else:
			movimiento_sm.travel("caminar")
	else:
		movimiento_sm.travel("idle")

func hold():
	defendiendo = true

func on_block_hit():
	if defendiendo:
		play_block_attack()

func on_anticipacion_completa():
	if Input.is_action_pressed("atacar"):
		esperando_soltar = true
		anim_tree["parameters/TimeScale_ataque/scale"] = 0.0

func _process(_delta: float) -> void:
	# interpolación suave del blend
	var blend_actual = anim_tree["parameters/Add2/add_amount"]
	anim_tree["parameters/Add2/add_amount"] = lerp(blend_actual, blend_objetivo, _delta * BLEND_VELOCIDAD)

	# resetear estaba_bloqueando solo cuando el blend llegó completamente a 0
	if blend_actual < 0.01 and blend_objetivo == 0.0:
		estaba_bloqueando = false

	# detectar fin de animación
	if animacion_en_curso:
		var progreso = ataque_sm.get_current_play_position()
		var duracion = ataque_sm.get_current_length()
		if duracion > 0 and progreso >= duracion - 0.05:
			_ataque_termino()
			return

	# movimiento SIEMPRE se actualiza
	_actualizar_movimiento()

	if player.inventario_abierto:
		defendiendo = false
		esperando_soltar = false
		blend_objetivo = 0.0
		timer_bloqueo.stop()
		player.desactivar_bloqueo()
		movimiento_sm.travel("idle")
		return

	if esperando_soltar:
		if not Input.is_action_pressed("atacar"):
			esperando_soltar = false
			anim_tree["parameters/TimeScale_ataque/scale"] = 1.0
		return

	var bloqueando = Input.is_action_pressed("bloquear")
	var atacando_input = Input.is_action_pressed("atacar") and is_instance_valid(player.arma)

	if bloqueando:
		if not defendiendo and not animacion_en_curso:
			defendiendo = true
			_iniciar_bloqueo()
		return

	if defendiendo:
		defendiendo = false
		anim_tree["parameters/TimeScale_ataque/scale"] = 1.0
		blend_objetivo = 0.0
		timer_bloqueo.stop()
		player.desactivar_bloqueo()

	if atacando_input:
		if not animacion_en_curso:
			play_random_animation()
		return

func play_random_animation():
	var current = ataque_sm.get_current_node()
	var disponibles = animaciones_arma.filter(func(a): return a != current)
	animacion_en_curso = true
	player.puede_correr = false
	blend_objetivo = 1.0
	if disponibles.is_empty():
		ataque_sm.travel(animaciones_arma[0])
	else:
		ataque_sm.travel(disponibles.pick_random())

func _iniciar_bloqueo():
	blend_objetivo = 1.0 # resetear por si estaba activo
	timer_bloqueo.stop()
	timer_bloqueo.start(TIEMPO_ACTIVACION_BLOQUEO)
	if player.arma != null:
		var blend_actual = anim_tree["parameters/Add2/add_amount"]
		var nodo_actual = ataque_sm.get_current_node()
		if nodo_actual == "bloqueo_arma":
			if blend_actual < 0.01:
				ataque_sm.start("bloqueo_arma")
		else:
			ataque_sm.travel("bloqueo_arma")
	elif player.secundaria != null:
		var blend_actual = anim_tree["parameters/Add2/add_amount"]
		var nodo_actual = ataque_sm.get_current_node()
		if nodo_actual == "hit_bloqueado":
			if blend_actual < 0.01:
				ataque_sm.start("hit_bloqueado")
		else:
			ataque_sm.travel("hit_bloqueado")
	estaba_bloqueando = true

func play_block_attack():
	if ataque_sm.get_current_node() == "hit_bloqueado" or ataque_sm.get_current_node() == "bloqueo_arma":
		return
	animacion_en_curso = true
	_iniciar_bloqueo()
