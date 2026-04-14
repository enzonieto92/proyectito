extends RayCast3D

var golpeando_enemigo = false

@onready var jugador: CharacterBody3D = $"../../../.."



func _process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		if collider.is_in_group("enemigos") and jugador.golpeando and not golpeando_enemigo:  # ✅ Lee el valor actual cada frame
			golpeando_enemigo = true
			jugador.golpeando = false
		else:
			golpeando_enemigo = false
