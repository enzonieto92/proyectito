extends RigidBody3D
var ya_toco_el_suelo = false

func _ready():
	contact_monitor = true
	max_contacts_reported = 4

func _integrate_forces(state):
	if ya_toco_el_suelo:
		return
	
	for i in state.get_contact_count():
		var colisionado = state.get_contact_collider_object(i)
		if colisionado != null and colisionado.is_in_group("paredes"):
			ya_toco_el_suelo = true
			eliminar_con_delay()
			break

func eliminar_con_delay():
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(self):
		queue_free()
