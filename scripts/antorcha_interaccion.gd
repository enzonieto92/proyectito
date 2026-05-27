extends StaticBody3D

@export var secundaria: Item

@onready var antorcha: Node3D = $".."
@onready var antorcha_malla: MeshInstance3D = $"../Antorcha"


var player_entered = false
func puede_interactuar() -> bool:
	return player_entered

func interactuar(player):
	print("interactuar llamado")
	var item_instancia = secundaria.duplicate()  
	var resultado = await player.inventario_controller.agregar_item(item_instancia)
	print("resultado agregar_item: ", resultado)
	if resultado:
		print("llamando apagar")
		antorcha.apagar()
		antorcha_malla.queue_free()
		queue_free()


func _on_area_interaccion_body_entered(body: Node3D) -> void:
	if body.name =="player":
		player_entered = true

func _on_area_interaccion_body_exited(body: Node3D) -> void:
	if body.name =="player":
		player_entered = false
