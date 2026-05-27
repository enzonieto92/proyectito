extends GridContainer

@export var slot_scene : PackedScene
@export var bg_items_color : Color

var grid_width : int
var grid_height : int
var grid = []
var slot_size: Vector2 = Vector2.ZERO


func _ready():
	grid_width = 4
	grid_height = 6
	columns = grid_width
	
	for x in range(grid_width):
		grid.append([])
		for y in range(grid_height):
			grid[x].append(null)
	
	for y in range(grid_height):
		for x in range(grid_width):
			var slot = slot_scene.instantiate()
			slot.setup(Vector2i(x, y))
			add_child(slot)
			grid[x][y] = slot
	
	if not Engine.is_editor_hint():
		# Forzar layout invisible para que global_position sea válida desde el inicio
		var inventario_ui = get_parent().get_parent()
		var era_visible = inventario_ui.visible
		if not era_visible:
			inventario_ui.modulate.a = 0
			inventario_ui.visible = true
		
		await get_tree().process_frame
		await get_tree().process_frame
		slot_size = grid[0][0].size
		
		if not era_visible:
			inventario_ui.visible = false
			inventario_ui.modulate.a = 1
func _on_inventario_ui_visibility_changed():
	if slot_size == Vector2.ZERO:
		await get_tree().process_frame
		await get_tree().process_frame
		slot_size = grid[0][0].size


func mostrar_item_visual(item, pos: Vector2i, era_visible: bool = true):
	var panel = get_parent()

	var bg = ColorRect.new()
	bg.color = bg_items_color
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.visible = false
	panel.add_child(bg)
	panel.move_child(bg, 1)

	var tex = TextureRect.new()
	tex.texture = item.icono
	tex.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.visible = false
	panel.add_child(tex)

	item.visual_node = tex
	item.visual_bg = bg

	_posicionar_visual.call_deferred(item, pos, era_visible)

func _posicionar_visual(item, pos: Vector2i, era_visible: bool):
	if not is_instance_valid(item.visual_node):
		return
	if not is_instance_valid(item.visual_bg):
		return

	var panel = get_parent()
	var inventario_ui = panel.get_parent()
	print("=== _posicionar_visual ===")
	print("era_visible: ", era_visible)
	print("inventario_ui.visible ahora: ", inventario_ui.visible)
	print("slot global_pos: ", grid[pos.x][pos.y].global_position)
	print("panel global_pos: ", panel.global_position)
	if not era_visible:
		item.visual_node.visible = false
		item.visual_bg.visible = false
		inventario_ui.visibility_changed.connect(
			func():
				await get_tree().process_frame
				await get_tree().process_frame
				_posicionar_visual(item, pos, true),
			CONNECT_ONE_SHOT
		)
		return

	var slot_origen = grid[pos.x][pos.y]
	var slot_size_local = grid[0][0].size
	var item_pixel_size = Vector2(item.size) * slot_size_local
	var local_pos = slot_origen.global_position - panel.global_position

	item.visual_bg.size = item_pixel_size
	item.visual_bg.position = local_pos
	item.visual_bg.visible = true

	item.visual_node.size = item_pixel_size
	item.visual_node.position = local_pos
	item.visual_node.visible = true
