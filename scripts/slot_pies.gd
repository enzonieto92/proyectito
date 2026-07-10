class_name PiesSlot extends slot_base

@onready var color_rect_2: ColorRect = $ColorRect2
@onready var sprite_casco: Sprite3D = get_tree().get_first_node_in_group("sprite_casco")

func get_color_rect() -> ColorRect: return color_rect_2
func get_sprite() -> Sprite3D: return sprite_casco
func _can_drop_data(_at_position: Vector2, data) -> bool:
	if not data is Dictionary or not data.has("item"): return false
	var cr = get_color_rect()
	if data["item"] is Botas:
		cr.modulate = Color(0.0, 1.0, 0.0, 1.0)
		return true
	if not acepta_item(data["item"]) or ocupado:
		cr.modulate = Color(1.0, 0.593, 0.533, 0.78)
		return false
	cr.modulate = Color(0.0, 1.0, 0.0, 1.0)
	return true
func acepta_item(nuevo_item) -> bool:
	return nuevo_item is Botas

func aplicar_stats(jugador, nuevo_item) -> void:
	jugador.botas = nuevo_item
	jugador.recalcular_velocidad()
	jugador.recalcular_armadura()

func quitar_stats(jugador) -> void:
	jugador.botas = null
	jugador.recalcular_velocidad()
	jugador.recalcular_armadura()

func get_drag_flags() -> Dictionary:
	return {"desde_weapon_slot": false, "desde_pies_slot": true, "pies_slot_ref": self}

func _get_stat_actual(jugador) -> int:
	return jugador.armadura

func _restaurar_stat(jugador) -> void:
	jugador.armadura_total = _stat_antes_drag

func _restar_stat_drag(jugador) -> void:
	jugador.armadura_total -= _item_en_drag.armadura
