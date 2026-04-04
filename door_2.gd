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
			pivote.rotation.y = deg_to_rad(65)
			abierta = true
		else:
			pivote.rotation.y = deg_to_rad(0)
			abierta = false
