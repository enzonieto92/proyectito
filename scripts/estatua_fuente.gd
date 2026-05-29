extends Node3D
var dialogo 
var texto_plano
var texto_notificacion
var sprite_arma
var sprite_arma_2
var daga_colocada : bool = false
@onready var daga_ritual: MeshInstance3D = $area_vision/daga_ritual
@onready var mujer: MeshInstance3D = $Mujer
@onready var area_vision: CollisionShape3D = $area_vision
@onready var area_interaccion: Area3D = $area_interaccion
@onready var antorcha_16: Node3D = $"../antorchas/antorcha16"
@onready var antorcha_17: Node3D = $"../antorchas/antorcha17"
@onready var sfx_sonido: AudioStreamPlayer3D = $SFX_sonido
@onready var sfx_sonido_2: AudioStreamPlayer3D = $SFX_sonido_2
@onready var sangre_particulas: GPUParticles3D = $sangre_particulas

var player_entered = false
func _ready() -> void:
	dialogo = get_tree().get_first_node_in_group("dialogo")
	texto_plano = get_tree().get_first_node_in_group("texto_plano")
	texto_notificacion = get_tree().get_first_node_in_group("texto_notificacion")
	sprite_arma = get_tree().get_first_node_in_group("sprite_arma")
	sprite_arma_2 = get_tree().get_first_node_in_group("sprite_arma_2")
func puede_interactuar() -> bool:
	return player_entered
func apagar_antorchas():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(antorcha_16.light, "light_energy", 0.0, 0.3)
	tween.tween_property(antorcha_17.light, "light_energy", 0.0, 0.3)
	sfx_sonido.play()
	sfx_sonido_2.play()
	tween.set_parallel(false)
	tween.tween_callback(func():
		print ("apagando antorchas")
		antorcha_16.apagar()
		antorcha_17.apagar()
	)
func interactuar(player):
	if daga_colocada == true:
		sangre_particulas.emitting = true
		get_tree().get_first_node_in_group("efecto_magia").activar(8.0)
		apagar_antorchas()
		var material = mujer.get_surface_override_material(1)
		if material == null:
			material = mujer.mesh.surface_get_material(1).duplicate()
			mujer.set_surface_override_material(1, material)
		const MAGICA = preload("uid://fabbshgqd5uo")
		AudioManager.fade_out(1, 2)
		var tween = create_tween()
		tween.tween_property(material, "albedo_color", Color(0.43, 0.047, 0.086, 0.494), 3.0)
		AudioManager.cambiar_ambiente(1, MAGICA, 1)
		AudioManager.fade_in(1, -24, 3)
		area_vision.disabled = true
		area_interaccion.monitoring = false
		# apaga la sangre al final de la transicion, no inmediatamente
		tween.tween_callback(func():
			sangre_particulas.emitting = false
			player.ritual_completo = true
			print (player.ritual_completo)
		)
	if player.arma != null:
		if player.arma.nombre == "Daga Ritual":
			player.arma = null
			daga_ritual.visible = true
			sprite_arma.texture = null
			sprite_arma_2.texture = null
			player.inventario_controller.remover_item_de_weapon_slot()
			daga_colocada = true
			texto_notificacion.show_text("daga colocada")
		else:
			dialogo.visible = true
			dialogo.show_text("Parece que esta rezando, o ¿rogando?")
	else:
		dialogo.visible = true
		dialogo.show_text("Parece que esta rezando, o ¿rogando?")

func _on_area_interaccion_body_entered(_body: Node3D) -> void:
	player_entered = true


func _on_area_interaccion_body_exited(_body: Node3D) -> void:
	player_entered = false
