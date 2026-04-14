extends Node
@onready var grid_container: GridContainer = $CanvasLayer/Inventario_UI/Panel/GridContainer
func _ready():
	add_to_group("inventario")
func agregar_item(item) -> bool:
	for y in range(grid_container.grid_height):
		for x in range(grid_container.grid_width):
			if puede_colocar(item, Vector2i(x, y)):
				item.grid_pos = Vector2i(x, y)
				for ix in range(item.size.x):
					for iy in range(item.size.y):
						var slot = grid_container.grid[x + ix][y + iy]
						slot.ocupado = true
						slot.item = item
				grid_container.mostrar_item_visual(item, Vector2i(x, y))
				return true
	return false

func puede_colocar(item, pos: Vector2i) -> bool:
	if pos.x + item.size.x > grid_container.grid_width or pos.y + item.size.y > grid_container.grid_height:
		return false
	for x in range(item.size.x):
		for y in range(item.size.y):
			if not grid_container.grid[pos.x + x][pos.y + y].esta_vacio():
				return false
	return true
func puede_colocar_ignorando_origen(item, pos: Vector2i, origen: Vector2i) -> bool:
	if pos.x + item.size.x > grid_container.grid_width or pos.y + item.size.y > grid_container.grid_height:
		return false
	for x in range(item.size.x):
		for y in range(item.size.y):
			var check = Vector2i(pos.x + x, pos.y + y)
			# ignorar los slots que ya ocupa el mismo item
			var es_propio = (check.x >= origen.x and check.x < origen.x + item.size.x and
							 check.y >= origen.y and check.y < origen.y + item.size.y)
			if not es_propio and not grid_container.grid[check.x][check.y].esta_vacio():
				return false
	return true
func mover_item(origen: Vector2i, destino: Vector2i, item):
	# limpiar slots origen
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[origen.x + ix][origen.y + iy]
			slot.ocupado = false
			slot.item = null

	# verificar que el destino tiene espacio
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			if destino.x + ix >= grid_container.grid_width or destino.y + iy >= grid_container.grid_height:
				_colocar_en(item, origen)
				return
			var slot = grid_container.grid[destino.x + ix][destino.y + iy]
			if slot.ocupado:
				_colocar_en(item, origen)
				return

	_colocar_en(item, destino)

func _colocar_en(item, pos: Vector2i):
	item.grid_pos = pos
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[pos.x + ix][pos.y + iy]
			slot.ocupado = true
			slot.item = item
	if item.visual_node:
		item.visual_node.queue_free()
	if item.visual_bg:
		item.visual_bg.queue_free()
	grid_container.mostrar_item_visual(item, pos)
