extends MeshInstance3D

@onready var pivote = $".."
@onready var sonido_celda: AudioStreamPlayer3D = $sonido_celda

var player_inside = false
@export var abierta = true

func _ready() -> void:
	setear_abierta()
func puede_interactuar():
	return player_inside

func setear_abierta():
		pivote.rotation.y = deg_to_rad(65)

func interactuar(_player):

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
