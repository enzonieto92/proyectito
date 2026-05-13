extends Node3D
var damage : Vector2 = Vector2(10,25)
var min_damage = damage.x
var max_damage = damage.y
@onready var sonido_switch: AudioStreamPlayer3D = $sonido_switch
@onready var sonido_pinchos: AudioStreamPlayer3D = $sonido_pinchos
@onready var animacion_pinchos: AnimationPlayer = $animacion_pinchos
var activado := false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if not body.is_in_group("jugador") or activado:
		return
	activado = true
	sonido_switch.play()
	await sonido_switch.finished
	sonido_pinchos.play()
	animacion_pinchos.play("trampa_activada")
	await get_tree().create_timer(0.13).timeout
	
	# pega si está adentro cuando los pinchos salen
	if $Area3D.overlaps_body(body):
		var _damage = int(randf_range(min_damage, max_damage))
		body.recibir_damage(_damage)
	
	await animacion_pinchos.animation_finished
	
	# pega si entró mientras los pinchos estaban afuera
	if $Area3D.overlaps_body(body):
		var _damage = int(randf_range(min_damage, max_damage))
		body.recibir_damage(_damage)
	
	animacion_pinchos.play_backwards("trampa_activada")
	await animacion_pinchos.animation_finished
	activado = false
