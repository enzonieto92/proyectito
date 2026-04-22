extends MeshInstance3D

@onready var pivote = $".."
@onready var sonido_celda: AudioStreamPlayer3D = $sonido_celda
@onready var celda_unlock: AudioStreamPlayer3D = $"celda unlock"

var player_inside = false
@export var abierta = false


func puede_interactuar():
	return player_inside


func interactuar(_player):

	sonido_celda.play()
	var tween = create_tween()

	if !abierta:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(65), 1.9)
		abierta = true
	else:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(0), 1.9)
		abierta = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_inside = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_inside = false
