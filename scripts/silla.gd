extends Node3D
@onready var dialogo: RichTextLabel = $"../UI/dialogo"
 # ajustá la ruta
var player_entered = false

func puede_interactuar():
	return player_entered

func interactuar(_player):
	dialogo.visible = true
	dialogo.show_text("alguien se sentó, y no arriba de esta")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_entered = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_entered = false
		if dialogo.visible:
			dialogo.stop_text()
