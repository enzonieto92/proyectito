extends StaticBody3D

@onready var animacion_ladrillo: AnimationPlayer = $"../animacion_ladrillo"

@onready var animacion_puerta: AnimationPlayer = $"../../../animacion_puerta"

var player_entered


func puede_interactuar():
	return player_entered
func interactuar(_player):
	animacion_ladrillo.play("activar_boton")
	await animacion_ladrillo.animation_finished
	animacion_puerta.play("abrir_compuerta")


func _on_area_interaccion_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		print ("player entered")
		player_entered = true

func _on_area_interaccion_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered = false
