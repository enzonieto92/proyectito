extends AnimationPlayer

@onready var player: CharacterBody3D = $".."
@onready var label_UI: Label = get_tree().get_first_node_in_group("label_animacion")
var defendiendo: bool = false

var animaciones_arma = ["atacar", "atacar_horizontal"]
var animacion_en_curso: bool = false

func _ready():
	play("idle")
	animation_finished.connect(_on_animation_finished)
func resetear_estado() -> void:
	animacion_en_curso = false
	defendiendo = false
	player.puede_correr = true 
	play("idle")
func _on_animation_finished(anim_name: String):
	if anim_name in animaciones_arma or anim_name == "hit_bloqueado":
		animacion_en_curso = false
		player.puede_correr = true
		if defendiendo:
			var anim = get_animation("bloquear")
			play("bloquear")
			seek(anim.length, true)
			pause()
		elif Input.is_action_pressed("atacar") and is_instance_valid(player.arma):
			
			play_random_animation()
	
	if anim_name == "bloquear":
		pause()
func hold():
	defendiendo = true

func on_block_hit():
	if defendiendo:
		play_block_attack()

func _process(_delta: float) -> void:
	label_UI.text = current_animation
	
	if player.inventario_abierto:
		if defendiendo:
			defendiendo = false
		if current_animation != "idle":
			play("idle")
		return
	
	var bloqueando = Input.is_action_pressed("bloquear")
	var atacando_input = Input.is_action_pressed("atacar") and is_instance_valid(player.arma)
	
	if bloqueando:
		if not defendiendo:
			defendiendo = true
			animacion_en_curso = false
			play("bloquear")
		return
	
	if defendiendo:
		defendiendo = false
		play("idle")
	
	if atacando_input:
		if not animacion_en_curso:
			
			play_random_animation()
			
		return
	
	if not animacion_en_curso:
		if player.moving:
			if player.corriendo and player.puede_correr:
				if current_animation != "correr":
					play("correr")
			else:
				if current_animation != "caminar":
					play("caminar")
		else:
			if current_animation != "idle":
				play("idle")

func play_random_animation():
	var disponibles = animaciones_arma.filter(func(a): return a != current_animation)
	animacion_en_curso = true
	player.puede_correr = false  # ← acá
	
	if disponibles.is_empty():
		play(animaciones_arma[0])
	else:
		play(disponibles.pick_random())

func play_block_attack():
	if current_animation == "hit_bloqueado":
		return
	
	animacion_en_curso = true
	play("hit_bloqueado")
