extends Area3D

@onready var dialogo =$"../../../CanvasLayer/dialogo"
@onready var area_in = $"../../../CanvasLayer/area_in"
@onready var raycast = $"../../../player/Camera3D/raycast"
var player_entered = false
var interactuado = false
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
		mirando = golpeado.name == "espada"

	if mirando and not dialogo.visible:
		area_in.text = "(E) Interactuar"
		area_in.visible = true
		if Input.is_action_just_pressed("interactuar"):
			area_in.visible = false
			dialogo.visible = true
			dialogo.show_text("esto es una espada sabes?")
			
	elif not mirando and dialogo.visible:
		# Dejó de mirar mientras el diálogo estaba activo
		dialogo.visible = false
		dialogo.text = ""
		dialogo.stop_text()

	elif not dialogo.visible:
		area_in.visible = false
