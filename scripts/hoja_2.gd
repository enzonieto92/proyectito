extends StaticBody3D

@onready var dialogo: RichTextLabel = get_tree().get_first_node_in_group("dialogo")

var player_entered = false

func puede_interactuar():
	return player_entered

func interactuar(_player):
	dialogo.visible = true
	dialogo.show_text(
		"\"No usar la llave hasta dar con una persona indicada.\n" +
		"Enkotena.. o Inketova no hará más que tomar su vida, como siempre...\n" +
	    "Presiento que estamos más cerca de confirmar el nombre del nuevo Dios.\""
	)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_entered = true
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_entered = false
		if dialogo.visible:
			dialogo.stop_text()
