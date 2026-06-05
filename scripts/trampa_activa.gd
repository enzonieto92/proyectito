extends Node3D
var damage : Vector2 = Vector2(10,25)
var min_damage = damage.x
var max_damage = damage.y
@onready var sonido_switch: AudioStreamPlayer3D = $sonido_switch
@onready var sonido_pinchos: AudioStreamPlayer3D = $sonido_pinchos
@onready var animacion_pinchos: AnimationPlayer = $animacion_pinchos
var activado := false
var ya_golpeo := false
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not (body.is_in_group("jugador") or body.is_in_group("enemigos")) or activado:
		return
	activado = true
	ya_golpeo = false
	sonido_switch.play()
	await sonido_switch.finished
	sonido_pinchos.play()
	animacion_pinchos.play("trampa_activada")
	await get_tree().create_timer(0.17).timeout
	
	if $Area3D.overlaps_body(body) and not ya_golpeo:
		ya_golpeo = true
		body.recibir_damage(damage, true)
	
	await animacion_pinchos.animation_finished
	
	if $Area3D.overlaps_body(body) and not ya_golpeo:
		ya_golpeo = true
		body.recibir_damage(damage, true)
	
	animacion_pinchos.play_backwards("trampa_activada")
	await animacion_pinchos.animation_finished
	activado = false
