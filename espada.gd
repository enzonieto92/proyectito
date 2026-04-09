extends StaticBody3D

@export var item: Item
@onready var area_interaccion = $area_interaccion


func puede_interactuar() -> bool:
	return area_interaccion.player_entered

func interactuar(player):
	if player.inv_controller.agregar_item(item):
		queue_free()
