# weapon_slot.gd
class_name WeaponSlot extends Control

@onready var color_rect_2: ColorRect = $ColorRect2
var ocupado: bool = false
var item = null
var slot_size: Vector2 = Vector2(32, 32)
static var drag_activo := false

@onready var sprite_arma: Sprite3D = get_tree().get_first_node_in_group("sprite_arma")

var _item_en_drag = null
var _drop_exitoso := false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# -------------------------
# JUGADOR
# -------------------------
func _aplicar_arma(jugador, arma):
	jugador.damage_arma = Vector2(arma.damage.x, arma.damage.y)
	jugador.total_damage.x = jugador.damage.x + arma.damage.x
	jugador.total_damage.y = jugador.damage.y + arma.damage.y
	jugador.arma = arma
	jugador.raycast_arma.target_position.y = arma.weapon_size

func _remover_arma(jugador):
	jugador.damage_arma = Vector2.ZERO
	jugador.total_damage.x = jugador.damage.x
	jugador.total_damage.y = jugador.damage.y
	jugador.arma = null
func equipar(nuevo_item) -> bool:
	if ocupado:
		return false
	if nuevo_item.tipo != Arma.Tipo.ARMA:
		return false

	var inventario = get_tree().get_first_node_in_group("inventario_controller")

	# Apagar hover antes de remover
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
	_aplicar_arma(jugador, item)
	_mostrar_icono()

	if sprite_arma:
		sprite_arma.texture = item.textura

	inventario.actualizar_label_peso()
	return true
# -------------------------
# HOVER
# -------------------------
func _on_mouse_entered():
	if not ocupado or drag_activo: return
	color_rect_2.modulate = Color(0.57, 0.57, 0.57, 0.529)

func _on_mouse_exited():
	if not ocupado or drag_activo: return
	color_rect_2.modulate = Color.WHITE

# -------------------------
# DRAG (sacar el item)
# -------------------------
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
	vaciar()

	if sprite_arma:
		sprite_arma.texture = null

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
		"desde_weapon_slot": true,
		"weapon_slot_ref": self
	}

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if not data is Dictionary or not data.has("item"):
		return false
	if data.get("desde_weapon_slot", false):
		return false
	if data["item"].tipo != Arma.Tipo.ARMA:
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
	inventario.remover_item_sin_actualizar_peso(data["item"], data["item"].grid_pos)  # 👈

	item = data["item"]
	ocupado = true

	var jugador = get_tree().get_first_node_in_group("jugador")
	_aplicar_arma(jugador, item)
	_mostrar_icono()

	if sprite_arma:
		sprite_arma.texture = item.textura

# -------------------------
# FIN DRAG
# -------------------------
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		drag_activo = false
		color_rect_2.modulate = Color.WHITE

		if not _drop_exitoso and _item_en_drag != null:
			item = _item_en_drag
			ocupado = true
			_mostrar_icono()
			if sprite_arma:
				sprite_arma.texture = item.textura

		_item_en_drag = null
		_drop_exitoso = false

# -------------------------
# VISUAL
# -------------------------
func _mostrar_icono():
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
	var icon = TextureRect.new()
	icon.name = "ItemIcon"
	icon.texture = item.icono
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2.ZERO
	icon.size = size
	add_child(icon)

func vaciar():
	ocupado = false
	item = null
	color_rect_2.modulate = Color.WHITE
	var jugador = get_tree().get_first_node_in_group("jugador")
	_remover_arma(jugador)
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
