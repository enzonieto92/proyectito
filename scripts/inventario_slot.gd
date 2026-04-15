class_name InventarioSlot 
extends Control

var grid_pos : Vector2i = Vector2i.ZERO
var ocupado: bool = false

@onready var color_rect_2: ColorRect = $ColorRect2
@onready var slot_background: TextureRect = $slot_background

var item = null
var slot_size: Vector2 = Vector2.ZERO 

# 🔥 estado global de drag
static var ultimo_highlight_pos: Vector2i = Vector2i(-1, -1)
static var ultimo_highlight_item = null
static var drag_activo := false


func setup(pos: Vector2i):
	grid_pos = pos


func esta_vacio() -> bool:
	return not ocupado


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


# -------------------------
# HOVER
# -------------------------

func _on_mouse_entered():
	if not ocupado or drag_activo:
		return
	
	_hover_item(item, item.grid_pos, true)


func _on_mouse_exited():
	if not ocupado or drag_activo:
		return
	
	_hover_item(item, item.grid_pos, false)


func _hover_item(it, pos: Vector2i, activo: bool):
	var grid = get_parent()
	var color = Color(0.57, 0.57, 0.57, 0.529) if activo else Color.WHITE
	
	for ix in range(it.size.x):
		for iy in range(it.size.y):
			var tx = pos.x + ix
			var ty = pos.y + iy
			
			if _en_rango(grid, tx, ty):
				grid.grid[tx][ty].color_rect_2.modulate = color


# -------------------------
# DRAG
# -------------------------

func _get_drag_data(at_position: Vector2):
	if not ocupado:
		return null
	
	drag_activo = true
	
	var grid = get_parent()
	slot_size = grid.slot_size
	
	if slot_size == Vector2.ZERO:
		slot_size = Vector2(32, 32)
	
	# 🔥 limpiar hover al empezar drag
	_hover_item(item, item.grid_pos, false)
	
	var drag_offset = grid_pos - item.grid_pos
	var item_pixel_size = Vector2(item.size) * slot_size
	
	# ocultar visual original
	if item.visual_node:
		item.visual_node.visible = false
	if item.visual_bg:
		item.visual_bg.visible = false
	
	var preview = TextureRect.new()
	preview.texture = item.icono
	preview.size = item_pixel_size
	preview.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	
	var container = Control.new()
	container.custom_minimum_size = item_pixel_size
	container.add_child(preview)
	
	# 🔥 offset correcto (pixel perfect real)
	var grab_offset = Vector2(drag_offset) * slot_size + at_position
	preview.position = -grab_offset
	
	set_drag_preview(container)
	
	return {
		"item": item,
		"origen": item.grid_pos,
		"drag_offset": drag_offset
	}


# -------------------------
# DROP
# -------------------------

func _can_drop_data(_at_position: Vector2, data) -> bool:
	if not data is Dictionary or not data.has("item"):
		return false
	
	var destino = grid_pos - data["drag_offset"]
	
	# limpiar highlight anterior
	if ultimo_highlight_item != null:
		_limpiar_highlight(ultimo_highlight_item, ultimo_highlight_pos)
	
	var inventario = get_tree().get_first_node_in_group("inventario")
	var puede = inventario.puede_colocar_ignorando_origen(
		data["item"], destino, data["origen"]
	)
	
	_highlight(data["item"], destino, puede)
	
	ultimo_highlight_pos = destino
	ultimo_highlight_item = data["item"]
	
	return puede


func _drop_data(_at_position: Vector2, data):
	var destino = grid_pos - data["drag_offset"]
	
	_limpiar_highlight(data["item"], destino)
	
	ultimo_highlight_item = null
	ultimo_highlight_pos = Vector2i(-1, -1)
	
	var inventario = get_tree().get_first_node_in_group("inventario")

	# Si viene de un WeaponSlot, agregarlo al inventario directamente
	# y avisarle al slot que el drop fue exitoso para que se vacíe
	if data.get("desde_weapon_slot", false):
		inventario._colocar_en(data["item"], destino)
		var weapon_slot = data.get("weapon_slot_ref")
		if weapon_slot:
			weapon_slot._drop_exitoso = true
			weapon_slot.vaciar()
	else:
		inventario.mover_item(data["origen"], destino, data["item"])

# -------------------------
# FIN DRAG
# -------------------------

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		
		drag_activo = false
		
		# restaurar visual
		if item:
			if item.visual_node:
				item.visual_node.visible = true
			if item.visual_bg:
				item.visual_bg.visible = true
		
		# 🔥 limpiar SIEMPRE todo
		if ultimo_highlight_item != null:
			_limpiar_highlight(ultimo_highlight_item, ultimo_highlight_pos)
			ultimo_highlight_item = null
			ultimo_highlight_pos = Vector2i(-1, -1)


# -------------------------
# HIGHLIGHT
# -------------------------

func _highlight(it, pos: Vector2i, puede: bool):
	var grid = get_parent()
	var color = Color(0.0, 1.0, 0.0, 1.0) if puede else Color(1.0, 0.593, 0.533, 0.78)
	
	for ix in range(it.size.x):
		for iy in range(it.size.y):
			var tx = pos.x + ix
			var ty = pos.y + iy
			
			if _en_rango(grid, tx, ty):
				grid.grid[tx][ty].color_rect_2.modulate = color


func _limpiar_highlight(it, pos: Vector2i):
	var grid = get_parent()
	
	for ix in range(it.size.x):
		for iy in range(it.size.y):
			var tx = pos.x + ix
			var ty = pos.y + iy
			
			if _en_rango(grid, tx, ty):
				grid.grid[tx][ty].color_rect_2.modulate = Color.WHITE


# -------------------------
# UTIL
# -------------------------

func _en_rango(grid, x, y):
	return x >= 0 and y >= 0 and x < grid.grid_width and y < grid.grid_height
