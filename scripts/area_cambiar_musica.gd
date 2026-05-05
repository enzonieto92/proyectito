extends Node3D
@export var pitch : float
@export var audio: AudioStreamMP3
@export var fade_in : bool
@export var volumen : float
@export_enum("sonido_ambiente_1", "sonido_ambiente_2", "sonido_ambiente_3") var sonido_elegido: int = 0


func _on_area_cambiar_musica_body_entered(_body: Node3D) -> void:
	if _body.is_in_group("jugador"):
		var tween = AudioManager.fade_out(sonido_elegido, 1)
		tween.tween_callback(func():
			AudioManager.cambiar_ambiente(sonido_elegido, audio, pitch)
			if fade_in:
				AudioManager.fade_in(sonido_elegido, volumen, 2)
			queue_free()  # ← acá
		)
