extends Node
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player: CharacterBody3D = $".."
@onready var label_UI: Label = get_tree().get_first_node_in_group("label_animacion")
var defendiendo: bool = false
var animaciones_arma = ["atacar", "atacar_horizontal"]
var animacion_en_curso: bool = false

func _ready():
	animation_player.play("idle")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	if player.inventario_abierto:
		if defendiendo:
			defendiendo = false
		if animacion_en_curso:
			animacion_en_curso = false
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		return
	if anim_name in animaciones_arma or anim_name == "hit_bloqueado":
		animacion_en_curso = false
		if defendiendo:
			var anim = animation_player.get_animation("bloquear")
			animation_player.play("bloquear")
			animation_player.seek(anim.length, true)
			animation_player.pause()
		elif Input.is_action_pressed("atacar") and is_instance_valid(player.arma):
			play_random_animation()
	
	if anim_name == "bloquear":
		animation_player.pause()

func hold():
	defendiendo = true

func on_block_hit():
	if defendiendo:
		play_block_attack()

func _process(_delta: float) -> void:
	label_UI.text = animation_player.current_animation
	
	if player.inventario_abierto:
		if defendiendo:
			defendiendo = false
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		return
	
	var bloqueando = Input.is_action_pressed("bloquear")
	var atacando_input = Input.is_action_pressed("atacar") and is_instance_valid(player.arma)
	
	if bloqueando:
		if not defendiendo:
			defendiendo = true
			animacion_en_curso = false
			animation_player.play("bloquear")
		return
	
	if defendiendo:
		defendiendo = false
		animation_player.play("idle")
	
	if atacando_input:
		if not animacion_en_curso:
			play_random_animation()
		return
	
	if not animacion_en_curso:
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
		animation_player.play(animaciones_arma[0])
	else:
		animation_player.play(disponibles.pick_random())

func play_block_attack():
	if animation_player.current_animation == "hit_bloqueado":
		return
	
	animacion_en_curso = true
	animation_player.play("hit_bloqueado")
