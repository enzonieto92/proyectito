extends CSGBox3D

@onready var pivote = $".."
@onready var sonido_puerta: AudioStreamPlayer = $"../../sonido_puerta"

var player_inside = false
@export var abierta = false


func _on_area_3d_body_entered(body):
	if body.name == "player":
		player_inside = true


func _on_area_3d_body_exited(body):
	if body.name == "player":
		player_inside = false


func puede_interactuar():
	return player_inside


func interactuar(_player):

	sonido_puerta.play()

	var tween = create_tween()

	if !abierta:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(65), 0.5)
		abierta = true
	else:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(0), 0.5)
		abierta = false
