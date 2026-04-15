# weapon_slot.gd
class_name WeaponSlot extends Control
@onready var color_rect_2: ColorRect = $ColorRect2
var ocupado: bool = false
var item = null
var slot_size: Vector2 = Vector2(32, 32)
static var drag_activo := false

@onready var sprite_arma: Sprite3D = get_tree().get_first_node_in_group("sprite_arma")

# Guardamos el item durante el drag para poder restaurarlo si falla
var _item_en_drag = null
var _drop_exitoso := false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
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

	# Guardamos referencia ANTES de vaciar
	_item_en_drag = item
	vaciar()
	# Limpiar sprite del arma al sacarla del slot
	if sprite_arma:
		sprite_arma.texture = null
	var preview = TextureRect.new()
	preview.texture = _item_en_drag.icono
	preview.size = slot_size
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var container = Control.new()
	container.custom_minimum_size = slot_size
	container.add_child(preview)
	preview.position = -slot_size / 2  # centrado respecto al cursor
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
	if data["item"].tipo != Item.Tipo.ARMA:
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
	var inventario = get_tree().get_first_node_in_group("inventario")
	inventario.remover_item(data["item"], data["item"].grid_pos)
	item = data["item"]
	var jugador = get_tree().get_first_node_in_group("jugador")
	jugador.damage_arma = item.damage
	jugador.total_damage = jugador.damage+ item.damage
	ocupado = true
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
				sprite_arma.texture = item.textura  # solo si se restaura

		_item_en_drag = null
		_drop_exitoso = false
# VISUAL
# -------------------------
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
	ocupado = false
	item = null
	color_rect_2.modulate = Color.WHITE
	var existing = get_node_or_null("ItemIcon")
	if existing: existing.queue_free()
