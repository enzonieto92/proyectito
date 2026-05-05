# Script en el nodo raíz "antorcha"
extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var light: OmniLight3D = $empty/SpotLight3D

func _on_visible_on_screen_notifier_3d_screen_entered():
	particles.emitting = true
	light.visible = true

func _on_visible_on_screen_notifier_3d_screen_exited():
	particles.emitting = false
	light.visible = false
	print ("ocultando particulas de antorcha")
