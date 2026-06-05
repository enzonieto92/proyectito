extends RayCast3D
@onready var enemigo: CharacterBody3D = $".."
@onready var player = get_tree().get_first_node_in_group("jugador")
var ya_golpeo: bool = false

func _process(delta: float) -> void:
	if enabled:
		intentar_golpe()
func intentar_golpe() -> void:
	look_at(player.position + Vector3(0,1, 0), Vector3.UP)
	force_raycast_update()

	if is_colliding() and not ya_golpeo:
		var obj = get_collider()
		print ("coll: ", obj)
		if obj.is_in_group("jugador"):
			enabled = false
			print ("hitting")
			obj.recibir_damage(enemigo.damage, false)
			ya_golpeo = true
