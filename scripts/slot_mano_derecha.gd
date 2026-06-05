class_name WeaponSlot extends slot_base

@onready var color_rect_2: ColorRect = $ColorRect2
@onready var sprite_1 = get_tree().get_first_node_in_group("sprite_arma")
@onready var sprite_2 = get_tree().get_first_node_in_group("sprite_arma_2")

func get_sprites() -> Array:
	return [sprite_1, sprite_2]
func get_color_rect() -> ColorRect: return color_rect_2

func acepta_item(nuevo_item) -> bool:
	return nuevo_item is Arma

func aplicar_stats(jugador, nuevo_item) -> void:
	jugador.damage_arma = Vector2(nuevo_item.damage.x, nuevo_item.damage.y)
	jugador.total_damage.x = jugador.damage.x + nuevo_item.damage.x
	jugador.total_damage.y = jugador.damage.y + nuevo_item.damage.y
	jugador.arma = nuevo_item
	jugador.raycast_arma.target_position.y = nuevo_item.weapon_size
func _remover_item_drop(inventario, nuevo_item) -> void:
	inventario.remover_item_sin_actualizar_peso(nuevo_item, nuevo_item.grid_pos)
func quitar_stats(jugador) -> void:
	jugador.damage_arma = Vector2.ZERO
	jugador.total_damage.x = jugador.damage.x
	jugador.total_damage.y = jugador.damage.y
	jugador.arma = null
func romper_arma() -> void:
	for spr in get_sprites():
		if spr: spr.texture = null
	vaciar()  # o el sprite de "sin arma"
func get_drag_flags() -> Dictionary:
	return {"desde_weapon_slot": true, "weapon_slot_ref": self}
# En WeaponSlot:
func _mostrar_icono() -> void:
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
	var icon = TextureRect.new()
	icon.name = "ItemIcon"
	icon.texture = item.icono
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2.ZERO
	icon.size = size  # 👈 diferente al default
	add_child(icon)
# WeaponSlot no necesita guardar/restaurar stats en el drag
# así que los overrides de _get_stat_actual, _restaurar_stat
# y _restar_stat_drag simplemente no se declaran → usan el pass de la base
