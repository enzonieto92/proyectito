class_name slot_eliminar extends slot_base

@onready var color_rect: ColorRect = $ColorRect

func get_color_rect() -> ColorRect:
	return color_rect

func _ready():
	super._ready()
	mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func acepta_item(_item) -> bool:
	return true

func _on_mouse_exited():
	color_rect.modulate = Color.WHITE

func _can_drop_data(at_position: Vector2, data) -> bool:
	# Dejamos que el base actualice ultimo_slot_hover y limpie highlights anteriores
	super._can_drop_data(at_position, data)
	if not data is Dictionary or not data.has("item"):
		return false
	color_rect.modulate = Color(1.0, 0.2, 0.2, 0.8)
	return true

func on_item_dropped(data) -> void:
	color_rect.modulate = Color.WHITE
	var inventario = get_tree().get_first_node_in_group("inventario_controller")
	item = data["item"]
	if data.has("inventario_slot_ref"):
		inventario.remover_item(item, item.grid_pos)
	for key in ["weapon_slot_ref", "secundary_slot_ref", "pechera_slot_ref", "casco_slot_ref"]:
		if data.has(key):
			data[key]._drop_exitoso = true

func equipar(_nuevo_item) -> bool:
	return false
