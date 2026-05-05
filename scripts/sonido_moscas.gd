extends Area3D

@export var audio: AudioStreamPlayer3D
@export var volumen_ocluido: float = -40.0



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		audio.volume_db = 0
		audio.attenuation_filter_db = 0


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		audio.volume_db = -40
		audio.attenuation_filter_db = -100
