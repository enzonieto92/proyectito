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
			# Abriendo menú: ocultar inventario si estaba abierto
			if inv_ui.visible:
				inv_ui.visible = false
				var player = get_tree().get_first_node_in_group("player")
				if player:
					player.inventario_abierto = false
			get_tree().paused = true
		else:
			# Cerrando menú: primero despausar, luego actualizar
			get_tree().paused = false
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.inventario_abierto = false
		
		_actualizar_ui()
# solo actualiza cuando cambia el estado

func _actualizar_ui() -> void:
	if mostrando_opciones:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dialogo.hide()
		texto_plano.hide()
		show()
	else:
		var player = get_tree().get_first_node_in_group("player")
		# Si el inv_ui no está visible, asegurarse que el player lo sepa
		if not inv_ui.visible:
			if player:
				player.inventario_abierto = false
		
		if inv_ui.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		dialogo.show()
		texto_plano.show()
		hide()
