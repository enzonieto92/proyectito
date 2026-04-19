extends Node

@onready var grid_container: GridContainer = $CanvasLayer/Inventario_UI/panel_mochila/GridContainer


func _ready():
	add_to_group("inventario")

func agregar_item(item) -> bool:
	if not is_instance_valid(item):
		push_error("agregar_item: item es null o inválido")
		return false
	
	var inventario_ui = grid_container.get_parent().get_parent()
	var era_visible = inventario_ui.visible
	
	# FORZAR LAYOUT
	if not era_visible:
		inventario_ui.visible = true
		inventario_ui.modulate.a = 0
	
	# 🔥 CLAVE: esperar 2 frames
	await get_tree().process_frame
	await get_tree().process_frame

	if not is_instance_valid(grid_container):
		return false
	for y in range(grid_container.grid_height):
		for x in range(grid_container.grid_width):
			var pos = Vector2i(x, y)
			
			if puede_colocar(item, pos):
				_colocar_en(item, pos)
				
				if not era_visible:
					inventario_ui.visible = false
					inventario_ui.modulate.a = 1
				
				return true
	
	if not era_visible:
		inventario_ui.visible = false
		inventario_ui.modulate.a = 1
	
	return false

func puede_colocar(item, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	
	if pos.x + item.size.x > grid_container.grid_width:
		return false
	if pos.y + item.size.y > grid_container.grid_height:
		return false
	
	for x in range(item.size.x):
		for y in range(item.size.y):
			if not grid_container.grid[pos.x + x][pos.y + y].esta_vacio():
				return false
	
	return true


func puede_colocar_ignorando_origen(item, pos: Vector2i, origen: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	
	if pos.x + item.size.x > grid_container.grid_width:
		return false
	if pos.y + item.size.y > grid_container.grid_height:
		return false
	
	for x in range(item.size.x):
		for y in range(item.size.y):
			var check = Vector2i(pos.x + x, pos.y + y)
			
			var es_propio = (
				check.x >= origen.x and check.x < origen.x + item.size.x and
				check.y >= origen.y and check.y < origen.y + item.size.y
			)
			
			if not es_propio and not grid_container.grid[check.x][check.y].esta_vacio():
				return false
	
	return true

func remover_item(item, origen: Vector2i):
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[origen.x + ix][origen.y + iy]
			slot.ocupado = false
			slot.item = null
			
func mover_item(origen: Vector2i, destino: Vector2i, item):
	if not puede_colocar_ignorando_origen(item, destino, origen):
		return
	
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[origen.x + ix][origen.y + iy]
			slot.ocupado = false
			slot.item = null
	
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
