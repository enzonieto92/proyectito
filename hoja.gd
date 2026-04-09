extends Area3D
@onready var dialogo = $"../../UI/dialogo"
@onready var area_in = $"../../UI/area_in"
@onready var raycast = $"../../player/Camera3D/raycast"
var player_entered = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_entered = true
func _on_body_exited(body: Node3D) -> void:
	if body.name == "player":
		area_in.text = ""
		area_in.visible = false
		dialogo.visible = false
		dialogo.text = ""
		dialogo.stop_text()
		player_entered = false

func _process(_delta: float) -> void:
	if not player_entered:
		return

	var mirando = false
	if raycast.is_colliding():
		var golpeado = raycast.get_collider()
		mirando = golpeado.name == "coll_hoja"

	if mirando and not dialogo.visible:
		area_in.text = "(E) Leer"
		area_in.visible = true
		if Input.is_action_just_pressed("interactuar"):
			area_in.visible = false
			dialogo.visible = true
			dialogo.show_text("
El hombre será torturado cuando despierte para saber quién lo envió. 
La mujer no habla. 
Evitar contacto directo con ella.
— M.”")

	elif not mirando and dialogo.visible:
		dialogo.visible = false
		dialogo.text = ""
		dialogo.stop_text()

	elif not dialogo.visible:
		area_in.visible = false
