extends Node3D

@onready var dialogo: RichTextLabel = get_tree().get_first_node_in_group("dialogo")

var player_entered = false

func puede_interactuar():
	return player_entered

func interactuar(_player):
	dialogo.visible = true
	dialogo.show_text("\"Catedral de Riáma- Registro interno -Año del Señor, 1343\n" +
"El ritual se completó en las tres sedes en el intervalo previsto.\n" +
"Riáma. Sero. La que no nombramos.\n" +
"No hubo desvíos en el procedimiento. Los hermanos cumplieron.\n" +
"La prisionera escapo antes de lo calculado. No es relevante ya.\n" +
"Nada cambiará lo que se movió esta noche.\n" +
"He recorrido esta catedral catorce años.\n" +
"Quien lea esto sepa que lo que hicimos aquí no fue fanatismo. Fue precisión.\n" +
"Años de trabajo metódico sobre algo que existía mucho antes que esta catedral,\n" +
"mucho antes que la orden, mucho antes que nosotros.\n" +
"M. Lo único que lament… (el resto es ilegible)\"")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_entered = true
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_entered = false
		if dialogo.visible:
			dialogo.stop_text()
