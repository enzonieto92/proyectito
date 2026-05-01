extends Node3D

@onready var pivote: Node3D = $".."
@onready var sonido_puerta: AudioStreamPlayer3D = $sonido_puerta

var resistencia : int = 40
var player_inside = false
@export var abierta = false


func _on_area_3d_body_entered(body):
	if body.name == "player":
		print ("player en area_puerta")
		player_inside = true


func _on_area_3d_body_exited(body):
	if body.name == "player":
		print ("player afuera de  area_puerta")
		player_inside = false


func puede_interactuar():
	print (player_inside)
	return player_inside

func romper():
	if resistencia <= 0:
		pass
func interactuar(_player):

	sonido_puerta.play()

	var tween = create_tween()

	if !abierta:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(65), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		abierta = true
	else:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(0), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		abierta = false
