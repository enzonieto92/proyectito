extends CSGBox3D

@onready var pivote = $".."
@onready var sonido_puerta = $EllvdrRechinarDePuertaSqueakingDoor6337111
var player_inside = false
var abierta = false

func _on_area_3d_body_entered(body):
	if body.name == "player":
		player_inside = true

func _on_area_3d_body_exited(body):
	if body.name == "player":
		player_inside = false
func _process(delta):
	if player_inside and Input.is_action_just_pressed("interactuar"):
		sonido_puerta.play(0)
		if !abierta:
			var tween = create_tween()
			tween.tween_property(pivote, "rotation:y", deg_to_rad(65), 0.5)
			abierta = true
		else:
			var tween = create_tween()
			tween.tween_property(pivote, "rotation:y", deg_to_rad(0), 0.5)
			abierta = false
