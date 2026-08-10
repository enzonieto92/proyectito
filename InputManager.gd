extends Node

enum Dispositivo { TECLADO_MOUSE, MANDO }

var dispositivo_actual: Dispositivo = Dispositivo.TECLADO_MOUSE
signal dispositivo_cambiado(nuevo: Dispositivo)

func _input(event: InputEvent) -> void:
	var nuevo_dispositivo = dispositivo_actual

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		nuevo_dispositivo = Dispositivo.TECLADO_MOUSE
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Para joypad motion, ignorar ruido de sticks/triggers en reposo
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.3:
			return
		nuevo_dispositivo = Dispositivo.MANDO

	if nuevo_dispositivo != dispositivo_actual:
		dispositivo_actual = nuevo_dispositivo
		dispositivo_cambiado.emit(dispositivo_actual)
