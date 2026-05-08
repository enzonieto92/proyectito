extends Node

var sonidos: Array[AudioStreamPlayer] = []

func _ready():
	for i in range(3):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sonidos.append(player)

func cambiar_ambiente(stream, audio, pitch):
	sonidos[stream].stream = audio
	sonidos[stream].pitch_scale = pitch
	sonidos[stream].play()

func fade_in(stream: int, final_vol: float, time: float):
	sonidos[stream].volume_db = -80.0
	var tween = create_tween()
	tween.tween_property(sonidos[stream], "volume_db", final_vol, time)
func detener_todo():
	for stream in sonidos:
		stream.stop()
func fade_out(stream: int, time: float):
	var tween = create_tween()
	tween.tween_property(sonidos[stream], "volume_db", -80.0, time)
	return tween
