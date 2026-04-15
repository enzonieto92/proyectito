extends RayCast3D
@onready var enemigo: CharacterBody3D = $".."
@onready var player: CharacterBody3D = $"../../player"

func _process(_delta: float) -> void:
	look_at(player.position, Vector3.UP)
	
	if is_colliding(): # Solo verifica la colisión
		var obj = get_collider()
		if obj.is_in_group("jugador"):
			obj.recibir_damage(enemigo.damage)
			set_enabled(false) # Desactiva para evitar múltiples golpes
