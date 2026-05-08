extends RayCast3D
var golpeando_enemigo = false
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
		enabled = false
		return

	enabled = true
	sonido_swing.play()
		
	if is_colliding():
		var collider = get_collider()  # 👈 primero obtenés el collider
		enabled = false              # 👈 después desactivás
		if collider.is_in_group("enemigos") and not golpeando_enemigo:
			golpeando_enemigo = true
			jugador.golpeando = false
			collider.recibir_damage(jugador.total_damage)
		elif collider.is_in_group("paredes"):
			animaciones.sonido = HIT_METAL
			jugador.rebotar_golpe = true
			jugador.golpeando = false
		elif collider.is_in_group("maderas"):
			animaciones.sonido = HIT_MADERA
			animaciones.sonido_arma.volume_db = -10
			jugador.rebotar_golpe = true
			jugador.golpeando = false
