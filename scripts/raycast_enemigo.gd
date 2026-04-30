extends RayCast3D
@onready var enemigo: CharacterBody3D = $".."
@onready var player: CharacterBody3D = $"../../player"

func _process(_delta: float) -> void:
	look_at(player.position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	
	if is_colliding(): # Solo verifica la colisión
		var obj = get_collider()
		if obj.is_in_group("jugador"):
			if obj.bloqueando == false:
				obj.recibir_damage(enemigo.damage) # Desactiva para evitar múltiples golpes
			else:
				print("bloqueado")
			set_enabled(false)
