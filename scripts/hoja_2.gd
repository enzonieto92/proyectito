extends StaticBody3D

@onready var dialogo: RichTextLabel = get_tree().get_first_node_in_group("dialogo")

var player_entered = false

func puede_interactuar():
	return player_entered

func interactuar(_player):
	dialogo.visible = true
	dialogo.show_text("La hoja 2 dice cosas que diria la HoJa DoX")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		print ("player entro en el area de la hoja")
		player_entered = true
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_entered = false
		if dialogo.visible:
			dialogo.stop_text()
