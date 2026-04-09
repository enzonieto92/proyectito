extends Control
class_name inventario_slot

@onready var icon = $Icon 

var item: Item = null

func esta_vacio() -> bool:
	return item == null

func set_item(nuevo_item: Item):
	item = nuevo_item
	
	if item.icono:
		icon.texture = item.icono
