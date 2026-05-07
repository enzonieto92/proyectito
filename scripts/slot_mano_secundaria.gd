#slot secundario
class_name SecundarySlot extends Control

@onready var color_rect_2: ColorRect = $ColorRect2
var ocupado: bool = false
var item = null
var slot_size: Vector2 = Vector2(32, 32)
static var drag_activo := false

@onready var sprite_secundaria: Sprite3D = get_tree().get_first_node_in_group("sprite_secundaria")

var _item_en_drag = null
var _drop_exitoso := false
var _armadura_antes_drag := 0  # 👈

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if not ocupado or drag_activo: return
	color_rect_2.modulate = Color(0.57, 0.57, 0.57, 0.529)
func _on_mouse_exited():
	if not ocupado or drag_activo: return
	color_rect_2.modulate = Color.WHITE
func equipar(nuevo_item) -> bool:
	if ocupado:
		return false
	if nuevo_item.tipo != Arma.Tipo.SECUNDARIA:
		return false

	var inventario = get_tree().get_first_node_in_group("inventario_controller")
		# ← apagar hover antes de remover, igual que WeaponSlot
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
	jugador.secundaria = item
	jugador.armadura_total = jugador.armadura +  item.armadura
	print ("equipando ", item.armadura, "armadura total ", jugador.armadura_total )
	_mostrar_icono()

	if sprite_secundaria:
		sprite_secundaria.texture = item.textura

	inventario.actualizar_label_peso()
	return true
func _get_drag_data(_at_position: Vector2):
	if not ocupado:
		return null
	drag_activo = true
	_drop_exitoso = false
	color_rect_2.modulate = Color.WHITE
	var icon = get_node_or_null("ItemIcon")
	if icon:
		icon.visible = false

	_item_en_drag = item
	# Guardar armadura antes del drag
	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador:
		_armadura_antes_drag = jugador.armadura  # 👈
	vaciar()
	if sprite_secundaria:
		sprite_secundaria.texture = null
	var preview = TextureRect.new()
	preview.texture = _item_en_drag.icono
	preview.size = slot_size
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var container = Control.new()
	container.custom_minimum_size = slot_size
	container.add_child(preview)
	preview.position = -slot_size / 2
	set_drag_preview(container)
	return {
		"item": _item_en_drag,
		"origen": Vector2i(-1, -1),
		"drag_offset": Vector2i.ZERO,
		"desde_weapon_slot": false,
		"desde_secundary_slot": true,
		"secundary_slot_ref": self
	}

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if not data is Dictionary or not data.has("item"):
		return false
	if data.get("desde_weapon_slot", false):
		return false
	if data["item"].tipo != Arma.Tipo.SECUNDARIA:
		color_rect_2.modulate = Color(1.0, 0.593, 0.533, 0.78)
		return false
	if ocupado:
		color_rect_2.modulate = Color(1.0, 0.593, 0.533, 0.78)
		return false
	color_rect_2.modulate = Color(0.0, 1.0, 0.0, 1.0)
	return true

func _drop_data(_at_position: Vector2, data):
	_drop_exitoso = true
	color_rect_2.modulate = Color.WHITE
	var inventario = get_tree().get_first_node_in_group("inventario_controller")
	inventario.remover_item(data["item"], data["item"].grid_pos)
	item = data["item"]
	var jugador = get_tree().get_first_node_in_group("jugador")
	jugador.damage_arma = Vector2(item.damage.x, item.damage.y)
	jugador.total_damage.x = (jugador.damage.x + item.damage.x)
	jugador.total_damage.y = (jugador.damage.y + item.damage.y)
	jugador.secundaria = item
	jugador.armadura_total = jugador.armadura + item.armadura
	ocupado = true
	_mostrar_icono()
	if sprite_secundaria:
		sprite_secundaria.texture = item.textura
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		drag_activo = false
		color_rect_2.modulate = Color.WHITE
		var jugador = get_tree().get_first_node_in_group("jugador")
		if not _drop_exitoso and _item_en_drag != null:
			item = _item_en_drag
			ocupado = true
			_mostrar_icono()
			if sprite_secundaria:
				sprite_secundaria.texture = item.textura
			if jugador:
				jugador.armadura_total = _armadura_antes_drag  # 👈 restaura exacto
		elif _drop_exitoso and _item_en_drag != null:
			if jugador:
				jugador.armadura_total -= _item_en_drag.armadura  # 👈 resta solo si fue exitoso
		_item_en_drag = null
		_drop_exitoso = false
		_armadura_antes_drag = 0  # 👈

func _mostrar_icono():
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
	var icon = TextureRect.new()
	icon.name = "ItemIcon"
	icon.texture = item.icono
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(icon)

func vaciar():  # 👈 solo visual, sin tocar armadura
	var jugador = get_tree().get_first_node_in_group("jugador")
	ocupado = false
	item = null
	color_rect_2.modulate = Color.WHITE
	jugador.secundaria = null
	jugador.armadura_total = jugador.armadura
	
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
