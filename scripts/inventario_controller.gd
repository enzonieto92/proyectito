extends Node

@onready var grid_container: GridContainer = $CanvasLayer/Inventario_UI/panel_mochila/GridContainer
@onready var label_peso: Label = $CanvasLayer/Inventario_UI/panel_mochila/label_peso
@export var peso_maximo: float = 20.0
@onready var slot_mano_derecha: WeaponSlot = $CanvasLayer/Inventario_UI/panel_equipo/slot_mano_derecha
@onready var slot_secundaria: SecundarySlot = $CanvasLayer/Inventario_UI/panel_equipo/slot_mano_secundaria
@onready var slot_pecho: PecheraSlot = $CanvasLayer/Inventario_UI/panel_equipo/slot_pecho
@onready var slot_cabeza: Control = $CanvasLayer/Inventario_UI/panel_equipo/slot_cabeza
@onready var tooltip: Control = $CanvasLayer/Inventario_UI/tooltip
@onready var tooltip_label: Label = $CanvasLayer/Inventario_UI/tooltip/tooltip_label
var primer_item_agregado: bool = false
func _ready():
	actualizar_label_peso()
func calcular_peso_total() -> float:
	var items_contados = {}
	var peso_total = 0.0
	
	for x in range(grid_container.grid_width):
		for y in range(grid_container.grid_height):
			var slot = grid_container.grid[x][y]
			if not slot.esta_vacio() and slot.item != null:
				var item = slot.item
				if not items_contados.has(item.get_instance_id()):
					items_contados[item.get_instance_id()] = true
					peso_total += item.weight
	return peso_total
func actualizar_label_peso():
	var peso = calcular_peso_total()
	label_peso.text = "Peso: %.1f/%.0f kg" % [peso, peso_maximo]
func agregar_item(item) -> bool:
	if not is_instance_valid(item):
		push_error("agregar_item: item es null o inválido")
		return false

	var inventario_ui = grid_container.get_parent().get_parent()
	var era_visible = inventario_ui.visible

	if not era_visible:
		inventario_ui.visible = true
		inventario_ui.modulate.a = 0
		if inventario_ui is Control:
			inventario_ui.update_minimum_size()
		if grid_container is Control:
			grid_container.update_minimum_size()

	if not is_instance_valid(grid_container):
		if not era_visible:
			inventario_ui.visible = false
			inventario_ui.modulate.a = 1
		return false

	var texto_notificacion = get_tree().get_first_node_in_group("texto_notificacion")
	for y in range(grid_container.grid_height):
		for x in range(grid_container.grid_width):
			var pos = Vector2i(x, y)
			if puede_colocar(item, pos):
				_colocar_en(item, pos, era_visible)  # ← pasamos era_visible
				actualizar_label_peso()
				if texto_notificacion:
					if item is Arma:
						texto_notificacion.show_text( "Arma añadida")
					if item is Consumible:
						texto_notificacion.show_text("Agarraste Comida")
					if item is Antorcha:
						texto_notificacion.show_text("Agarraste una Antorcha")
					if item is Pechera or item is Casco:
						texto_notificacion.show_text("Agarraste Equipo")

				if not era_visible:
					inventario_ui.visible = false
					inventario_ui.modulate.a = 1
				if not primer_item_agregado:
					primer_item_agregado = true
					get_tree().get_first_node_in_group("texto_instruccion").show_text("Presiona (TAB)", 1)
				return true

	if not era_visible:
		inventario_ui.visible = false
		inventario_ui.modulate.a = 1
	texto_notificacion.show_text("No puedo cargar mas")
	return false

func _colocar_en(item, pos: Vector2i, era_visible: bool = true):
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

	grid_container.mostrar_item_visual(item, pos, era_visible)  # ← pasamos era_visible
func mostrar_tooltip(it):
	if it is String:
		tooltip_label.text = it
	else:
		tooltip_label.text = it.descripcion
	tooltip.show()
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
func remover_item_sin_actualizar_peso(item, origen: Vector2i):
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[origen.x + ix][origen.y + iy]
			slot.ocupado = false
			slot.item = null
func remover_item(item, origen: Vector2i):
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[origen.x + ix][origen.y + iy]
			slot.ocupado = false
			slot.item = null
	
	if item.visual_node:
		item.visual_node.queue_free()
		item.visual_node = null
	if item.visual_bg:
		item.visual_bg.queue_free()
		item.visual_bg = null
	
	actualizar_label_peso()
func remover_item_buscando(item) -> bool:
	for x in range(grid_container.grid_width):
		for y in range(grid_container.grid_height):
			var slot = grid_container.grid[x][y]
			if slot.item != null and is_instance_valid(slot.item):
				if slot.item.nombre == item.nombre:  # igual que tiene_item
					remover_item(slot.item, Vector2i(x, y))  # usamos slot.item, no item
					return true
	return false
func remover_equipado() -> void:
	var slots_equipados = [
		slot_mano_derecha,
		slot_secundaria,
	]
	for slot in slots_equipados:
		if slot.item != null and is_instance_valid(slot.item):
			slot.romper_arma()
func mover_item(origen: Vector2i, destino: Vector2i, item):
	if not puede_colocar_ignorando_origen(item, destino, origen):
		return
	
	for ix in range(item.size.x):
		for iy in range(item.size.y):
			var slot = grid_container.grid[origen.x + ix][origen.y + iy]
			slot.ocupado = false
			slot.item = null
	
	_colocar_en(item, destino)

func tiene_item(item_buscado) -> bool:
	if not is_instance_valid(item_buscado):
		return false
	for x in range(grid_container.grid_width):
		for y in range(grid_container.grid_height):
			var slot = grid_container.grid[x][y]
			if slot.item != null and is_instance_valid(slot.item):
				if slot.item.nombre == item_buscado.nombre:
					return true
	return false
func remover_item_de_weapon_slot() -> void:
	slot_mano_derecha.vaciar()  # ya limpia el slot, remueve arma del jugador y el icono
