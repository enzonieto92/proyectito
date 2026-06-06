extends RayCast3D
@onready var enemigo: CharacterBody3D = $".."
@onready var player = get_tree().get_first_node_in_group("jugador")
var ya_golpeo: bool = false

func _process(_delta: float) -> void:
	if enabled:
		look_at(player.global_position + Vector3(0,1.0, 0))
		intentar_golpe()
func intentar_golpe() -> void:
	force_raycast_update()

	if is_colliding() and not ya_golpeo:
		var obj = get_collider()
		if obj.is_in_group("jugador"):
			enabled = false
			obj.recibir_damage(Vector2(enemigo.min_damage, enemigo.max_damage), false)
			ya_golpeo = true
