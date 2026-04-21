extends StaticBody3D

@export var secundaria: Secundaria
@onready var sprite: MeshInstance3D = $sprite

func _ready() -> void:
	var material = StandardMaterial3D.new()
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = secundaria.textura
	sprite.set_surface_override_material(0, material)
var player_entered = false
func puede_interactuar() -> bool:
	return player_entered

func interactuar(player):
	if await player.inventario_controller.agregar_item(secundaria):
		print ("agregando item")
		queue_free()


func _on_area_interaccion_body_entered(body: Node3D) -> void:
	if body.name =="player":
		player_entered = true

func _on_area_interaccion_body_exited(body: Node3D) -> void:
	if body.name =="player":
		player_entered = false
