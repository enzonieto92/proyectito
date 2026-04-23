extends Node3D

@onready var panel_opciones: Panel = $UI/panel_opciones
@onready var dialogo: RichTextLabel = $UI/dialogo
@onready var texto_plano: RichTextLabel = $UI/texto_plano
var inv_ui
var mostrando_opciones: bool = false

func _ready() -> void:
	inv_ui = get_tree().get_first_node_in_group("inventario_ui")
	get_viewport().grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_actualizar_ui()  # estado inicial

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc") and not event.is_echo():
		mostrando_opciones = !mostrando_opciones
		_actualizar_ui()  # solo actualiza cuando cambia el estado

func _actualizar_ui() -> void:
	if mostrando_opciones:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dialogo.show()
		texto_plano.show()
		panel_opciones.show()
	else:
		if inv_ui.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		dialogo.hide()
		texto_plano.hide()
		panel_opciones.hide()
