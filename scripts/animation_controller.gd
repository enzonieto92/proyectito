extends Node

@onready var anim_tree: AnimationTree = $"../AnimationTree"
@onready var movimiento_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/movimiento/playback"]
@onready var ataque_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/ataque/playback"]
@onready var player: CharacterBody3D = $".."
@onready var timer_bloqueo: Timer = Timer.new()
var spawning := false
var instruccion : RichTextLabel
var defendiendo: bool = false
var esperando_soltar := false
var boost_daño_activo := false
const MULTIPLICADOR_BOOST: float = 1.7
const ANIMACIONES_POR_TIPO = {
	Arma.TipoArma.ESPADA: ["atacar", "atacar_horizontal"],
	Arma.TipoArma.LANZA:  ["atacar_lanza_1", "atacar_lanza_2"],
	Arma.TipoArma.MAZA:   ["atacar", "atacar_horizontal"],
	Arma.TipoArma.DAGA:   ["atacar", "atacar_horizontal"],
}
var animaciones_arma: Array = []
var animacion_en_curso: bool = false
var blend_objetivo: float = 0.0
var estaba_bloqueando: bool = false
const BLEND_VELOCIDAD: float = 5.0
const TIEMPO_ACTIVACION_BLOQUEO: float = 0.2  # ajustá este valor

@onready var sonido_swing: AudioStreamPlayer = $"../pivote/posicion_arma/sprite_arma/sonido_swing"
@onready var sonido_arma: AudioStreamPlayer = $"../pivote/posicion_arma/sprite_arma/sonido_arma"
@onready var sonido : AudioStreamMP3
func _ready():
	instruccion = get_tree().get_first_node_in_group("texto_instruccion")
	anim_tree.active = true
	anim_tree["parameters/Add2/add_amount"] = 0.0
	movimiento_sm.travel("idle")
	add_child(timer_bloqueo)
	timer_bloqueo.one_shot = true
	timer_bloqueo.timeout.connect(_on_bloqueo_listo)
func stop() -> void:
	anim_tree.active = false
	timer_bloqueo.stop()
func _on_bloqueo_listo():
	if defendiendo:
		player.activar_bloqueo()
		await get_tree().process_frame
func resetear_estado() -> void:
	animacion_en_curso = false
	defendiendo = false
	esperando_soltar = false
	estaba_bloqueando = false

	player.puede_correr = false
	player.moving = false
	player.corriendo = false

	blend_objetivo = 0.0

	timer_bloqueo.stop()
	player.desactivar_bloqueo()

	movimiento_sm.travel("idle")
func _ataque_termino():
	print(" scale actual: ", anim_tree["parameters/TimeScale_ataque/scale"])
	anim_tree["parameters/TimeScale_ataque/scale"] = 1.0
	animacion_en_curso = false
	player.puede_correr = true

	blend_objetivo = 0.0
	if defendiendo:
		_iniciar_bloqueo()
	elif Input.is_action_pressed("atacar") and is_instance_valid(player.arma) and player.stamina >= player.arma.gasto_stamina and not player.stamina_agotada:
		play_attack_animation()

func _actualizar_movimiento():
	if spawning:       # ← no pisar la animación
		return
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
		boost_daño_activo = true  # ← se activa la carga
		player.animacion_arma()
		anim_tree["parameters/TimeScale_ataque/scale"] = 0.0
	elif player.arma != null:
		player.stamina = max(0.0, player.stamina - player.arma.gasto_stamina)

func _process(_delta: float) -> void:
	if player.muerto:  # ← cortar todo si está muerto
		return
	var blend_actual = anim_tree["parameters/Add2/add_amount"]
	anim_tree["parameters/Add2/add_amount"] = lerp(blend_actual, blend_objetivo, _delta * BLEND_VELOCIDAD)

	if blend_actual < 0.01 and blend_objetivo == 0.0:
		estaba_bloqueando = false

	# detectar fin de spawn
	if spawning:
		var progreso = movimiento_sm.get_current_play_position()
		var duracion = movimiento_sm.get_current_length()
		if duracion > 0 and progreso >= duracion - 0.05:
			spawning = false
			animacion_en_curso = false
			player.puede_correr = true
		return  # ← no procesar nada más mientras spawna

		# detectar fin de animación normal
	if animacion_en_curso:
		var progreso = ataque_sm.get_current_play_position()
		var duracion = ataque_sm.get_current_length()
		if _manejar_rebote(progreso):
			return
		if duracion > 0 and progreso >= duracion - 0.05:
			_ataque_termino()
			return
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
			anim_tree["parameters/TimeScale_ataque/scale"] = 1.5
			player.stamina = max(0.0, player.stamina - player.arma.gasto_stamina)  # ← gasto al soltar
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
		if instruccion.visible:
			instruccion.ocultar()
			instruccion.show_text("(Click Der) para Bloquear", 4)
		if not animacion_en_curso and player.stamina >= player.arma.gasto_stamina and not player.stamina_agotada:
			play_attack_animation()
		return
func _manejar_rebote(progreso: float) -> bool:
	if player.rebotar_golpe:
		sonido_swing.stop()
		player.golpeando = false        # ← forzar a false directamente
		var anim_player = anim_tree.get_node(anim_tree.anim_player)
		var anim = anim_player.get_animation(ataque_sm.get_current_node())
		if anim:
			anim.track_set_enabled(0, false)
		player.rebotar_golpe = false
		blend_objetivo = 0.0
		sonido_arma.stop()
		sonido_arma.stream = sonido
		sonido_arma.play()
		anim_tree["parameters/TimeScale_ataque/scale"] = -1.0
	if anim_tree["parameters/TimeScale_ataque/scale"] < 0.0 and progreso <= 0.05:
		anim_tree["parameters/TimeScale_ataque/scale"] = 1.0
		esperando_soltar = Input.is_action_pressed("atacar") 
		_ataque_termino()
		return true

	return false
func play_attack_animation():
	var tipo = player.arma.tipo

	animaciones_arma = ANIMACIONES_POR_TIPO.get(tipo, ["atacar"])
	
	var current = ataque_sm.get_current_node()
	var disponibles = animaciones_arma.filter(func(a): return a != current)
	animacion_en_curso = true
	player.puede_correr = false
	blend_objetivo = 1.0
	var ap = anim_tree.get_node(anim_tree.anim_player)
	if disponibles.is_empty():
		ataque_sm.travel(animaciones_arma[0])
		var anim = ap.get_animation(animaciones_arma[0])
		if anim: anim.track_set_enabled(0, true)
	else:
		var elegida = disponibles.pick_random()
		ataque_sm.travel(elegida)
		var anim = ap.get_animation(elegida)
		if anim: anim.track_set_enabled(0, true)
func play_spawn():
	spawning = true
	animacion_en_curso = true
	player.puede_correr = false
	movimiento_sm.travel("spawn")

func _iniciar_bloqueo():
	blend_objetivo = 1.0
	timer_bloqueo.stop()
	timer_bloqueo.start(TIEMPO_ACTIVACION_BLOQUEO)
	if instruccion.visible:
		instruccion.ocultar()
	var tiene_escudo = player.secundaria != null and player.secundaria is Escudo

	if tiene_escudo:
		var nodo_actual = ataque_sm.get_current_node()
		if nodo_actual == "bloquear":
			if anim_tree["parameters/Add2/add_amount"] < 0.01:
				ataque_sm.start("bloquear")
		else:
			ataque_sm.travel("bloquear")
	elif player.arma != null:
		var nodo_actual = ataque_sm.get_current_node()
		if nodo_actual == "bloqueo_arma":
			if anim_tree["parameters/Add2/add_amount"] < 0.01:
				ataque_sm.start("bloqueo_arma")
		else:
			ataque_sm.travel("bloqueo_arma")
	else:
		return

	estaba_bloqueando = true
func play_block_attack():
	if anim_tree["parameters/shot_bloquear/active"]:
		return
	anim_tree["parameters/shot_bloquear/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	animacion_en_curso = true
	player.puede_correr = false
