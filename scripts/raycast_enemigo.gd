extends RayCast3D
@onready var enemigo: CharacterBody3D = $".."
@onready var player = get_tree().get_first_node_in_group("jugador")
var ya_golpeo: bool = false

func _process(_delta: float) -> void:
	look_at(player.position + Vector3(0,1.4,0), Vector3.UP)

	if is_colliding() and not ya_golpeo:
		set_enabled(false)
		var obj = get_collider()
		print (obj)
		if obj.is_in_group("jugador"):
			print ("hitting player")
			ya_golpeo = true        # ← bloquear inmediatamente
			obj.recibir_damage(enemigo.damage, false)
	
