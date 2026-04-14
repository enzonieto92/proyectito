extends GridContainer

@export var slot_scene : PackedScene
@export var bg_items_color : Color
var grid_width : int
var grid_height : int
var grid = []

func _ready():
	grid_width = 6
	grid_height = 4
	columns = grid_width

	# inicializar array 2D primero
	for x in range(grid_width):
		grid.append([])
		for y in range(grid_height):
			grid[x].append(null)

	# agregar slots iterando Y primero para que GridContainer los ubique bien
	for y in range(grid_height):
		for x in range(grid_width):
			var slot = slot_scene.instantiate()
			slot.setup(Vector2i(x, y))
			add_child(slot)
			grid[x][y] = slot 
func mostrar_item_visual(item, pos: Vector2i):
	await get_tree().process_frame
	await get_tree().process_frame
	notification(NOTIFICATION_SORT_CHILDREN)
	
	var slot_size = grid[0][0].size
	var margin = Vector2(0, 0)  # margen horizontal y vertical entre slots
	var slot_origen = grid[pos.x][pos.y]
	
	# tamaño total incluyendo márgenes internos entre slots
	var item_pixel_size = Vector2(item.size) * slot_size + Vector2(item.size - Vector2i(1, 1)) * margin
	
	var scale_factor = 1
	var display_size = item_pixel_size * scale_factor
	
	var tex_size = Vector2(item.icono.get_width(), item.icono.get_height())
	var offset = (tex_size - display_size) / 2
	offset.y += 16
	
	var atlas = AtlasTexture.new()
	atlas.atlas = item.icono
	atlas.region = Rect2(offset, display_size)
	
	var panel = get_parent()
	var local_pos = slot_origen.global_position - panel.global_position
	
	# fondo de debug
	var bg = ColorRect.new()
	bg.color = bg_items_color
	bg.size = item_pixel_size
	bg.position = local_pos
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	panel.add_child(bg)
	panel.move_child(bg, 0)  # bg al fondo
	
	var tex = TextureRect.new()
	tex.texture = atlas
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tex.size = item_pixel_size
	tex.position = local_pos
	panel.add_child(tex)
	# tex al final = encima de todo, sin move_child
	item.visual_node = tex
	item.visual_bg = bg
