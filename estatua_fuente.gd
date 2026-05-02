extends Node3D
var dialogo 
var sprite_arma
var daga_colocada : bool = false
@onready var daga_ritual: MeshInstance3D = $area_vision/daga_ritual
@onready var mujer: MeshInstance3D = $Mujer
@onready var area_vision: CollisionShape3D = $area_vision
@onready var area_interaccion: Area3D = $area_interaccion

var player_entered = false
func _ready() -> void:
	dialogo = get_tree().get_first_node_in_group("dialogo")
	sprite_arma = get_tree().get_first_node_in_group("sprite_arma")
func puede_interactuar() -> bool:
	return player_entered
func interactuar(player):
	if daga_colocada == true:
		var material = mujer.get_surface_override_material(1)
		if material == null:
			material = mujer.mesh.surface_get_material(1).duplicate()
			mujer.set_surface_override_material(1, material)
		var tween = create_tween()
		tween.tween_property(material, "albedo_color", Color(0.43, 0.047, 0.086, 0.494), 3.0)
		area_vision.disabled = true
		area_interaccion.monitoring = false
	if player.arma != null:
		if player.arma.nombre == "Daga Ritual":
			player.arma = null
			daga_ritual.visible = true
			sprite_arma.texture = null
			player.inventario_controller.remover_item_de_weapon_slot()
			daga_colocada = true
		
	else:
		dialogo.visible = true
		dialogo.show_text("Parece que esta rezando, o ¿rogando?")

func _on_area_interaccion_body_entered(_body: Node3D) -> void:
	player_entered = true


func _on_area_interaccion_body_exited(_body: Node3D) -> void:
	player_entered = false
