extends Panel
@onready var boton_salir: Button = $GridContainer/boton_salir
@onready var reiniciar_escena: Button = $GridContainer/reiniciar_escena
var mostrando_opciones: bool = false
@onready var dialogo: RichTextLabel = $"../dialogo"
@onready var texto_plano: RichTextLabel = $"../texto_plano"
var inv_ui

func _ready() -> void:
	inv_ui = get_tree().get_first_node_in_group("inventario_ui")
	boton_salir.pressed.connect(salir)
	reiniciar_escena.pressed.connect(restart)
	process_mode = Node.PROCESS_MODE_ALWAYS

func salir():
	get_tree().quit()

func restart():
	get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and not event.is_echo():
		mostrando_opciones = !mostrando_opciones
		
		if mostrando_opciones:
			# Abriendo menú: cerrar inventario si estaba abierto
			if inv_ui.visible:
				var player = get_tree().get_first_node_in_group("player")
				if player and player.has_method("cerrar_inventario"):
					player.cerrar_inventario()
			get_tree().paused = true
		else:
			# Cerrando menú: despausar y dejar que el player maneje su estado
			get_tree().paused = false
		
		_actualizar_ui()

func _actualizar_ui() -> void:
	if mostrando_opciones:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dialogo.hide()
		texto_plano.hide()
		show()
	else:
		# NO tocar mouse mode acá — el player lo maneja en cerrar_inventario
		dialogo.show()
		texto_plano.show()
		hide()
