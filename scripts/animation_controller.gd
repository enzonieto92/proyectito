extends Node

@onready var anim_tree: AnimationTree = $"../AnimationTree"
@onready var movimiento_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/movimiento/playback"]
@onready var ataque_sm: AnimationNodeStateMachinePlayback = anim_tree["parameters/ataque/playback"]
@onready var player: CharacterBody3D = $".."

var defendiendo: bool = false
var esperando_soltar := false
var animaciones_arma = ["atacar", "atacar_horizontal"]
var animacion_en_curso: bool = false

func _ready():
	anim_tree.active = true
	anim_tree["parameters/Add2/add_amount"] = 0.0
	movimiento_sm.travel("idle")

func resetear_estado() -> void:
	animacion_en_curso = false
	defendiendo = false
	esperando_soltar = false
	player.puede_correr = true
	anim_tree["parameters/Add2/add_amount"] = 0.0
	movimiento_sm.travel("idle")

func _ataque_termino():
	animacion_en_curso = false
	player.puede_correr = true
	anim_tree["parameters/Add2/add_amount"] = 0.0
	if defendiendo:
		ataque_sm.travel("bloquear")
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
	# detectar fin de animación
	if animacion_en_curso:
		var progreso = ataque_sm.get_current_play_position()
		var duracion = ataque_sm.get_current_length()
		if duracion > 0 and progreso >= duracion - 0.05:
			_ataque_termino()

	# movimiento SIEMPRE se actualiza
	_actualizar_movimiento()

	if player.inventario_abierto:
		defendiendo = false
		esperando_soltar = false
		anim_tree["parameters/Add2/add_amount"] = 0.0
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
		if not defendiendo:
			defendiendo = true
			animacion_en_curso = false
			anim_tree["parameters/Add2/add_amount"] = 1.0
			ataque_sm.travel("bloquear")
		return

	if defendiendo:
		defendiendo = false
		anim_tree["parameters/TimeScale_ataque/scale"] = 1.0
		anim_tree["parameters/Add2/add_amount"] = 0.0

	if atacando_input:
		if not animacion_en_curso:
			play_random_animation()
		return

func play_random_animation():
	var current = ataque_sm.get_current_node()
	var disponibles = animaciones_arma.filter(func(a): return a != current)
	animacion_en_curso = true
	player.puede_correr = false
	anim_tree["parameters/Add2/add_amount"] = 1.0
	if disponibles.is_empty():
		ataque_sm.travel(animaciones_arma[0])
	else:
		ataque_sm.travel(disponibles.pick_random())

func play_block_attack():
	if ataque_sm.get_current_node() == "hit_bloqueado":
		return
	animacion_en_curso = true
	anim_tree["parameters/Add2/add_amount"] = 1.0
	ataque_sm.travel("hit_bloqueado")
