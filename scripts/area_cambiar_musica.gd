extends Node3D
@export var pitch : float
@export var audio: AudioStreamMP3
@export var fade_in : bool
@export_enum("sonido_ambiente_1", "sonido_ambiente_2", "sonido_ambiente_3") var sonido_elegido: int = 0

var sonidos: Array[AudioStreamPlayer]

func _ready():
	sonidos = [
		get_node("../../../../sonido_ambiente_1"),
		get_node("../../../../sonido_ambiente_2"),
		get_node("../../../../sonido_ambiente_3")
	]

func _on_area_cambiar_musica_body_entered(_body: Node3D) -> void:
	if _body.is_in_group("jugador"):
		sonidos[sonido_elegido].stream = audio
		sonidos[sonido_elegido].pitch_scale = pitch
		sonidos[sonido_elegido].play()
		if fade_in:
			sonidos[sonido_elegido].volume_db = -80.0
			var tween = create_tween()
			tween.tween_property(sonidos[sonido_elegido], "volume_db", -24.0, 3.0)
			await tween.finished
		queue_free()
