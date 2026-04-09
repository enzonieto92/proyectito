extends Control

class_name inventario_controller

@onready var inventario_grid: GridContainer = %GridContainer
var inventario_slot_prefab: PackedScene = load("res://InventarioSlot.tscn")

var item_slots_count: int = 16
var inventario_slots: Array[inventario_slot] = []
var inventario_full: bool = false


func _ready() -> void:
	for i in item_slots_count:
		var slot = inventario_slot_prefab.instantiate() as inventario_slot
		
		if slot == null:
			push_error("No se pudo instanciar InventarioSlot")
			continue
			
		inventario_grid.add_child(slot)
		inventario_slots.append(slot)


func agregar_item(item: Item) -> bool:
	if item == null:
		push_error("Intentaste agregar un item null")
		return false

	for slot in inventario_slots:
		if slot and slot.esta_vacio():
			slot.set_item(item)
			return true
	
	inventario_full = true
	print("Inventario lleno")
	return false
