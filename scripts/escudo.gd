extends StaticBody3D

@export var secundaria: Secundaria
@onready var sprite: MeshInstance3D = $sprite

var player_entered = false
func puede_interactuar() -> bool:
	return player_entered

func interactuar(player):
	if await player.inventario_controller.agregar_item(secundaria):
		queue_free()


func _on_area_interaccion_body_entered(body: Node3D) -> void:
	if body.name =="player":
		player_entered = true

func _on_area_interaccion_body_exited(body: Node3D) -> void:
	if body.name =="player":
		player_entered = false
