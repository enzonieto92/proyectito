extends Control
var grid_pos : Vector2i = Vector2i.ZERO
var ocupado: bool = false
@onready var slot_background: TextureRect = $slot_background
var item = null

static var ultimo_highlight_pos: Vector2i = Vector2i(-1, -1)
static var ultimo_highlight_item = null

func setup(pos: Vector2i):
	grid_pos = pos

func esta_vacio() -> bool:
	return not ocupado

func _get_drag_data(at_position: Vector2):
	if not ocupado:
		return null
	
	var drag_offset = grid_pos - item.grid_pos
	
	# tamaño de slot para calcular el desplazamiento en píxeles
	var slot_size = get_parent().grid[0][0].size
	var margin = Vector2(3, 3)
	var slot_step = slot_size + margin  # tamaño de un slot + su margen
	
	var preview = TextureRect.new()
	preview.texture = item.icono
	preview.size = Vector2(64, 64)
	# offset en píxeles: centrado + desfasaje por el slot clickeado
	preview.position = -preview.size / 2 - Vector2(drag_offset) * slot_step
	
	var container = Control.new()
	container.add_child(preview)
	set_drag_preview(container)
	
	return { "item": item, "origen": item.grid_pos, "drag_offset": drag_offset }
func _can_drop_data(at_position: Vector2, data) -> bool:
	if not data is Dictionary or not data.has("item"):
		return false
	
	# destino real = slot hover - offset
	var destino = grid_pos - data["drag_offset"]
	
	if ultimo_highlight_pos != destino and ultimo_highlight_item != null:
		_limpiar_highlight(ultimo_highlight_item, ultimo_highlight_pos)
	
	var inventario = get_tree().get_first_node_in_group("inventario")
	var puede = inventario.puede_colocar_ignorando_origen(data["item"], destino, data["origen"])
	_highlight(data["item"], destino, puede)
	
	ultimo_highlight_pos = destino
	ultimo_highlight_item = data["item"]
	
	return puede

func _drop_data(at_position: Vector2, data):
	var destino = grid_pos - data["drag_offset"]
	_limpiar_highlight(data["item"], destino)
	ultimo_highlight_pos = Vector2i(-1, -1)
	ultimo_highlight_item = null
	var inventario = get_tree().get_first_node_in_group("inventario")
	inventario.mover_item(data["origen"], destino, data["item"])

func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if ultimo_highlight_item != null:
			_limpiar_highlight(ultimo_highlight_item, ultimo_highlight_pos)
			ultimo_highlight_pos = Vector2i(-1, -1)
			ultimo_highlight_item = null

func _highlight(it, pos: Vector2i, puede: bool):
	var grid = get_parent()
	var color = Color(0, 1, 0, 0.4) if puede else Color(1, 0, 0, 0.4)
	for ix in range(it.size.x):
		for iy in range(it.size.y):
			var tx = pos.x + ix
			var ty = pos.y + iy
			if tx >= 0 and ty >= 0 and tx < grid.grid_width and ty < grid.grid_height:
				grid.grid[tx][ty].slot_background.modulate = color

func _limpiar_highlight(it, pos: Vector2i):
	var grid = get_parent()
	for ix in range(it.size.x):
		for iy in range(it.size.y):
			var tx = pos.x + ix
			var ty = pos.y + iy
			if tx >= 0 and ty >= 0 and tx < grid.grid_width and ty < grid.grid_height:
				grid.grid[tx][ty].slot_background.modulate = Color.WHITE
