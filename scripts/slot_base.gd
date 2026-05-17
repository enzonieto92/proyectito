# base_equipment_slot.gd
class_name slot_base extends Control

var ocupado: bool = false
var item = null
var slot_size: Vector2 = Vector2(32, 32)
static var drag_activo := false
var _item_en_drag = null
var _drop_exitoso := false
var _stat_antes_drag := 0

# ── Métodos abstractos que cada hijo sobreescribe ──────────────────
func get_color_rect() -> ColorRect:
	return null  # override obligatorio

func get_sprites() -> Array:
	return []  # override obligatorio

func acepta_item(_nuevo_item) -> bool:
	return false  # override obligatorio

func aplicar_stats(_jugador, _nuevo_item) -> void:
	pass  # override obligatorio

func quitar_stats(_jugador) -> void:
	pass  # override obligatorio

func get_drag_flags() -> Dictionary:
	return {}  # override: {"desde_secundary_slot": true, "secundary_slot_ref": self}

# ── Lógica común ───────────────────────────────────────────────────
func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if not ocupado or drag_activo: return
	get_color_rect().modulate = Color(0.57, 0.57, 0.57, 0.529)

func _on_mouse_exited():
	if not ocupado or drag_activo: return
	get_color_rect().modulate = Color.WHITE

func _mostrar_icono():
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
	var icon = TextureRect.new()
	icon.name = "ItemIcon"
	icon.texture = item.icono
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(icon)

func vaciar():
	var jugador = get_tree().get_first_node_in_group("jugador")
	ocupado = false
	item = null
	get_color_rect().modulate = Color.WHITE
	quitar_stats(jugador)
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()

func equipar(nuevo_item) -> bool:
	if ocupado or not acepta_item(nuevo_item):
		return false

	var inventario = get_tree().get_first_node_in_group("inventario_controller")
	var slot_origen = inventario.grid_container.grid[nuevo_item.grid_pos.x][nuevo_item.grid_pos.y]
	slot_origen._hover_item(nuevo_item, nuevo_item.grid_pos, false)
	inventario.remover_item_sin_actualizar_peso(nuevo_item, nuevo_item.grid_pos)

	if nuevo_item.visual_node:
		nuevo_item.visual_node.queue_free()
		nuevo_item.visual_node = null
	if nuevo_item.visual_bg:
		nuevo_item.visual_bg.queue_free()
		nuevo_item.visual_bg = null

	item = nuevo_item
	ocupado = true

	var jugador = get_tree().get_first_node_in_group("jugador")
	aplicar_stats(jugador, item)
	_mostrar_icono()

	for spr in get_sprites():
		if spr: spr.texture = item.textura
	

	inventario.actualizar_label_peso()
	return true

func _get_drag_data(_at_position: Vector2):
	if not ocupado: return null
	drag_activo = true
	_drop_exitoso = false
	get_color_rect().modulate = Color.WHITE

	var icon = get_node_or_null("ItemIcon")
	if icon: icon.visible = false

	_item_en_drag = item
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		_stat_antes_drag = _get_stat_actual(jugador)  # 👇 ver abajo
	vaciar()
	for spr in get_sprites():
		if spr: spr.texture = null

	var preview = TextureRect.new()
	preview.texture = _item_en_drag.icono
	preview.size = slot_size
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var container = Control.new()
	container.custom_minimum_size = slot_size
	container.add_child(preview)
	preview.position = -slot_size / 2
	set_drag_preview(container)

	var flags = get_drag_flags()
	flags["item"] = _item_en_drag
	flags["origen"] = Vector2i(-1, -1)
	flags["drag_offset"] = Vector2i.ZERO
	return flags

func _get_stat_actual(_jugador) -> int:
	return 0  # override si necesitás guardar un stat específico

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if not data is Dictionary or not data.has("item"): return false
	var cr = get_color_rect()
	if not acepta_item(data["item"]) or ocupado:
		cr.modulate = Color(1.0, 0.593, 0.533, 0.78)
		return false
	cr.modulate = Color(0.0, 1.0, 0.0, 1.0)
	return true
func _drop_data(_at_position: Vector2, data):
	_drop_exitoso = true
	get_color_rect().modulate = Color.WHITE
	
	var slot_origen = data.get("inventario_slot_ref")
	if slot_origen and data["item"] is Consumible:
		slot_origen._intentar_equipar()
		return
	
	equipar(data["item"])
func _remover_item_drop(inventario, nuevo_item) -> void:
	inventario.remover_item(nuevo_item, nuevo_item.grid_pos)  # comportamiento default


func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		drag_activo = false
		var cr = get_color_rect()
		if cr: cr.modulate = Color.WHITE
		var jugador = get_tree().get_first_node_in_group("jugador")
		if not _drop_exitoso and _item_en_drag != null:
			item = _item_en_drag
			ocupado = true
			_mostrar_icono()
			for spr in get_sprites():
				if spr: spr.texture = item.textura
			if jugador: _restaurar_stat(jugador)
		_item_en_drag = null
		_drop_exitoso = false
		_stat_antes_drag = 0

func _restaurar_stat(_jugador) -> void:
	pass  # override

func _restar_stat_drag(_jugador) -> void:
	pass  # override
