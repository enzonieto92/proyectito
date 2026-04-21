extends Node

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player: CharacterBody3D = $".."
@onready var label_UI: Label = get_tree().get_first_node_in_group("label_animacion")

var atacando: bool = false
var defendiendo: bool = false
var animaciones_arma = ["atacar", "atacar_horizontal"]
var animacion_en_curso: bool = false

func _ready():
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name in animaciones_arma:
		animacion_en_curso = false
		if Input.is_action_pressed("atacar") and is_instance_valid(player.arma):
			play_random_animation()

func hold():
	animation_player.pause()
	defendiendo = true

func _process(_delta: float) -> void:
	label_UI.text = animation_player.current_animation
	var bloqueando = Input.is_action_pressed("bloquear") and not player.inventario_abierto
	var atacando_input = Input.is_action_pressed("atacar") and not player.inventario_abierto and is_instance_valid(player.arma)

	# BLOQUEO (máxima prioridad, cancela TODO)
	if bloqueando:
		if not defendiendo:
			atacando = false
			animacion_en_curso = false # CLAVE: limpiás estado roto
			animation_player.play("bloquear")
		return

	# SALIR DE BLOQUEO
	if defendiendo:
		defendiendo = false
		animation_player.play("idle")

	# ATAQUE (solo si NO está bloqueando)
	if atacando_input:
		if not animacion_en_curso:
			play_random_animation()
		return

	# MOVIMIENTO / IDLE
	if not animacion_en_curso:
		atacando = false
		
		if player.moving:
			if player.corriendo:
				if animation_player.current_animation != "correr":
					animation_player.play("correr")
			else:
				if animation_player.current_animation != "caminar":
					animation_player.play("caminar")
		else:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")

func play_random_animation():
	var disponibles = animaciones_arma.filter(func(a): return a != animation_player.current_animation)
	animacion_en_curso = true
	
	if disponibles.is_empty():
		animation_player.stop()
		animation_player.play(animaciones_arma[0])
	else:
		animation_player.play(disponibles.pick_random())
