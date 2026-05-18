extends StaticBody3D

@export var secundaria: Item
@onready var sprite: MeshInstance3D = $sprite
@onready var antorcha: Node3D = $".."


var player_entered = false
func puede_interactuar() -> bool:
	return player_entered

func interactuar(player):
	print("interactuar llamado")
	var resultado = await player.inventario_controller.agregar_item(secundaria)
	print("resultado agregar_item: ", resultado)
	if resultado:
		print("llamando apagar")
		antorcha.apagar()
		queue_free()


func _on_area_interaccion_body_entered(body: Node3D) -> void:
	if body.name =="player":
		player_entered = true

func _on_area_interaccion_body_exited(body: Node3D) -> void:
	if body.name =="player":
		player_entered = false
