extends RayCast3D
@onready var enemigo: CharacterBody3D = $".."
@onready var player = get_tree().get_first_node_in_group("jugador")
var ya_golpeo: bool = false

func _process(_delta: float) -> void:
	look_at(player.position, Vector3.UP)
	rotation.x = 0
	rotation.z = 0
	
	if is_colliding() and not ya_golpeo:
		var obj = get_collider()
		if obj.is_in_group("jugador"):
			print ("golpeando", ya_golpeo)
			ya_golpeo = true        # ← bloquear inmediatamente
			set_enabled(false)
			obj.recibir_damage(enemigo.damage)
