extends Node3D

const TENSION_1_INDEX = 1  # índice del clip en el AudioStreamInteractive

func _on_area_cambiar_musica_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		var musica = body.get_node("Musica")
		var playback = musica.get_stream_playback() as AudioStreamPlaybackInteractive
		playback.switch_to_clip_by_name("Tension 1")  # nombre del clip en el recurso
		# o por índice:
		# playback.switch_to_clip(1)
		queue_free()
