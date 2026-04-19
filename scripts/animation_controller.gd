extends Node

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player: CharacterBody3D = $".."

var atacando: bool = false
var animaciones_arma = ["atacar", "atacar_horizontal"]
var animacion_en_curso: bool = false
func _ready():
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if anim_name in animaciones_arma:
		animacion_en_curso = false
		# solo continúa si el botón SIGUE presionado en este momento
		if Input.is_action_pressed("atacar") and is_instance_valid(player.arma):
			play_random_animation()

func _process(_delta: float) -> void:
	if Input.is_action_pressed("atacar") and not player.inventario_abierto and is_instance_valid(player.arma):
		if not animacion_en_curso:
			play_random_animation()
	elif not animacion_en_curso:
		atacando = false
		if player.moving and not player.inventario_abierto:
			if player.corriendo:
				if animation_player.current_animation != "correr":
					animation_player.play("correr")
			else:
				animation_player.play("caminar")
		else:
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
func play_random_animation():
	var disponibles = animaciones_arma.filter(func(a): return a != animation_player.current_animation)
	animacion_en_curso = true  # bloqueás al inicio de cada animación
	if disponibles.is_empty():
		animation_player.stop()
		animation_player.play(animaciones_arma[0])
	else:
		animation_player.play(disponibles.pick_random())
