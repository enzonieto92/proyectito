extends RayCast3D
var golpeando_enemigo = false
var sonido_reproducido := false
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
		
	if is_colliding():
		var collider = get_collider()
		enabled = false
		jugador.golpeando = false
		if collider.is_in_group("enemigos") and not golpeando_enemigo:
			jugador.arma.durabilidad -= 3
			golpeando_enemigo = true
			collider.recibir_damage(jugador.total_damage)
		else:
			if collider.is_in_group("paredes"):
				jugador.arma.durabilidad -= 10
				animaciones.sonido = HIT_METAL
				jugador.rebotar_golpe = true
			elif collider.is_in_group("maderas"):
				animaciones.sonido = HIT_MADERA
				jugador.arma.durabilidad -= 7
				animaciones.sonido_arma.volume_db = -10
				jugador.rebotar_golpe = true
		if jugador.arma.durabilidad <= 0:
			jugador.arma = null
			jugador.romper_arma()
