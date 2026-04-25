extends Node3D

var _tiempo := 0.0
var _shake_intensidad := 0.0
var _shake_duracion := 0.0
@export var frecuencia : float
func _process(delta: float) -> void:
	_tiempo += delta
	_shake_duracion -= delta
	var offset := sin(_tiempo * frecuencia) * _shake_intensidad
	position.x = offset
	if _shake_duracion < 0.0:
		_shake_intensidad = lerp(_shake_intensidad, 0.0, 3 * delta)
		position.x = lerp(position.x, 0.0, 1.0 * delta)
		position.z = lerp(position.x, 0.0, 1.0 * delta)
		position.y = lerp(position.x, 0.0, 1.0 * delta)
func shake(intensidad: float, duracion: float, freq: float) -> void:
	_shake_intensidad = intensidad
	_shake_duracion = duracion
	frecuencia = freq
