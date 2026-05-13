extends Node3D
var damage : Vector2 = Vector2(10,25)
var min_damage = damage.x
var max_damage = damage.y
@onready var sonido_switch: AudioStreamPlayer3D = $sonido_switch
@onready var sonido_pinchos: AudioStreamPlayer3D = $sonido_pinchos
@onready var animacion_pinchos: AnimationPlayer = $animacion_pinchos

func _on_area_3d_body_entered(body: Node3D) -> void:
	sonido_switch.play()
	await sonido_switch.finished
	sonido_pinchos.play()
	animacion_pinchos.play("trampa_activada")
	if body.is_in_group("jugador"):
		var _damage = int(randf_range(min_damage, max_damage)) 
		body.recibir_damage(_damage)
	await animacion_pinchos.animation_finished
	animacion_pinchos.play_backwards("trampa_activada")
