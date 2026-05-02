extends Node3D

@onready var pivote: Node3D = $".."
@onready var sonido_puerta: AudioStreamPlayer3D = $sonido_puerta
@onready var puerta_rota = preload("res://escenas/puerta_destruida.tscn")
var resistencia : int = 40
var player_inside = false
@export var abierta = false
@onready var puerta: MeshInstance3D = $puerta
@onready var puerta_colision: CollisionShape3D = $puerta_colision


func _on_area_3d_body_entered(body):
	if body.name == "player":
		player_inside = true


func _on_area_3d_body_exited(body):
	if body.name == "player":
		player_inside = false
func hit_puerta():
	$hit_puerta.play()

func puede_interactuar():
	return player_inside
func interactuar(_player):

	sonido_puerta.play()

	var tween = create_tween()

	if !abierta:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(65), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		abierta = true
	else:
		tween.tween_property(pivote, "rotation:y", deg_to_rad(0), 4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		abierta = false
func romper():
	puerta.visible = false          # ← ocultar ya
	puerta_colision.disabled = true # ← desactivar colision ya
	puerta.queue_free()
	puerta_colision.queue_free()
	
	var instancia = puerta_rota.instantiate()
	$break_puerta.play()
	add_child(instancia)
	
	for child in instancia.get_children():
		if child is RigidBody3D:
			var direccion = Vector3(randf_range(-1, 1), randf_range(0.5, 1), randf_range(-1, 1)).normalized()
			child.apply_impulse(direccion * randf_range(2.0, 3.0))
