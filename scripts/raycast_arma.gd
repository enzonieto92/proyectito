extends RayCast3D
var golpeando_enemigo = false
@onready var jugador: CharacterBody3D = get_tree().get_first_node_in_group("jugador")

func _process(_delta: float) -> void:
	# Resetear cuando NO está golpeando (nuevo swing)
	if not jugador.golpeando:
		golpeando_enemigo = false
		return

	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("enemigos") and not golpeando_enemigo:
			golpeando_enemigo = true
			collider.recibir_damage(jugador.total_damage)
			
			print("vida enemigo:", collider.vida)
