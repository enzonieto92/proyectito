extends RayCast3D
var golpeando_enemigo = false
var sonido_reproducido := false
const SANGRE = preload("res://escenas/sangre_particulas.tscn")
@onready var jugador: CharacterBody3D = get_tree().get_first_node_in_group("jugador")
@onready var sonido_swing: AudioStreamPlayer = $"../sonido_swing"
@onready var animaciones: AnimationPlayer 
const HIT_METAL = preload("uid://n3w8dyh66sy4")
const HIT_MADERA = preload("uid://fvpedxsvhad8")

func _ready() -> void:
	animaciones = jugador.get_node("animaciones")

func _process(_delta: float) -> void:
	if not jugador.golpeando:
		golpeando_enemigo = false
		sonido_reproducido = false
		enabled = false
		return

	if not sonido_reproducido:
		sonido_reproducido = true
		sonido_swing.play()
		enabled = true

	if not is_colliding():
		return

	var collider = get_collider()
	print (collider)
	# Primero procesás el hit, DESPUÉS desactivás
	if collider.is_in_group("enemigos") and not golpeando_enemigo:
		collider.recibir_damage(jugador.total_damage, false)

		var sangre = SANGRE.instantiate()
		get_tree().root.add_child(sangre)
		sangre.global_position = get_collision_point()
		sangre.emitting = true
		golpeando_enemigo = true
		if jugador.arma != null and is_instance_valid(jugador.arma):
			jugador.arma.durabilidad -= 3


	elif collider.is_in_group("paredes"):
		print ("paredes")
		jugador.arma.durabilidad -= 10
		animaciones.sonido = HIT_METAL
		jugador.rebotar_golpe = true

	elif collider.is_in_group("maderas"):
		print ("maderas")
		animaciones.sonido = HIT_MADERA
		jugador.arma.durabilidad -= 7
		animaciones.sonido_arma.volume_db = -10
		jugador.rebotar_golpe = true

	if jugador.arma != null and jugador.arma.durabilidad <= 0:
		jugador.arma = null
		jugador.romper_arma()

	# Desactivás al final, cuando ya procesaste todo
	enabled = false
	jugador.golpeando = false
