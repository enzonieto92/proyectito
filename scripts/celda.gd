extends MeshInstance3D

@onready var pivote = $".."
@onready var sonido_celda: AudioStreamPlayer3D = $sonido_celda
@onready var celda: Node3D = $"../.."
var llave_celda 
var player_inside = false
var abierta = false
var requiere_llave = false

func _ready() -> void:
	llave_celda = celda.llave
	abierta = celda.abierta
	requiere_llave = celda.requiere_llave
	if abierta:
		pivote.rotation.y = deg_to_rad(65)
func puede_interactuar():
	return player_inside

func interactuar(_player):
	var inventario = _player.inventario_controller

	if requiere_llave:
		if inventario.tiene_item(llave_celda):
			requiere_llave = false
		else:
			print("no tiene la llave el pete")
	else:
		var tween = create_tween()
		if !abierta:
			tween.tween_property(pivote, "rotation:y", deg_to_rad(65), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			abierta = true
		else:
			tween.tween_property(pivote, "rotation:y", deg_to_rad(0), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
			abierta = false
		sonido_celda.play()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_inside = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_inside = false
