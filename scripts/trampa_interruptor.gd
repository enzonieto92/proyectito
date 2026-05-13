extends Node3D
var activado = false
@onready var animacion: AnimationPlayer = $animacion
@onready var sonido_interruptor: AudioStreamPlayer3D = $sonido_interruptor

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		activado = true
		animacion.play("activar_interruptor")
		sonido_interruptor.play()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		activado = false
		animacion.play_backwards("activar_interruptor")
