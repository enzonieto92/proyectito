extends GridContainer

@export var slot_scene : PackedScene
@export var bg_items_color : Color

var grid_width : int
var grid_height : int
var grid = []
var slot_size: Vector2 = Vector2.ZERO


func _ready():
	grid_width = 6
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
	
	# 🔥 CLAVE: inicializar tamaño real SIEMPRE
	await get_tree().process_frame
	await get_tree().process_frame
	
	slot_size = grid[0][0].size

func _on_inventario_ui_visibility_changed():
	if slot_size == Vector2.ZERO:
		await get_tree().process_frame
		await get_tree().process_frame
		slot_size = grid[0][0].size


func mostrar_item_visual(item, pos: Vector2i):
	await get_tree().process_frame
	await get_tree().process_frame
	
	notification(NOTIFICATION_SORT_CHILDREN)
	
	var slot_size_local = grid[0][0].size
	var slot_origen = grid[pos.x][pos.y]
	
	var item_pixel_size = Vector2(item.size) * slot_size_local 

	# ❌ BORRÁ todo esto, era para texturas 128x128
	# var tex_size = ...
	# var offset = ...
	# var atlas = AtlasTexture.new()

	var panel = get_parent()
	var local_pos = slot_origen.global_position - panel.global_position
	
	var bg = ColorRect.new()
	bg.color = bg_items_color
	bg.size = item_pixel_size
	bg.position = local_pos
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(bg)
	panel.move_child(bg, 1)
	
	var tex = TextureRect.new()
	tex.texture = item.icono
	tex.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED  # ← centrado
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.size = item_pixel_size
	tex.position = local_pos
	panel.add_child(tex)
	
	item.visual_node = tex
	item.visual_bg = bg
