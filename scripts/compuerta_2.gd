extends Node3D
@onready var animacion_compuerta_2: AnimationPlayer = $"../../../animacion_compuerta_2"
@onready var sonido_antorcha: AudioStreamPlayer3D = $"../sonido_antorcha"

var player_entered = false

func puede_interactuar():
	return player_entered
	
func interactuar(_player):
	sonido_antorcha.play()
	animacion_compuerta_2.play("abrir")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		print ("player entered")
		player_entered = true
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered = false
