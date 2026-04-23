extends Panel

@onready var boton_salir: Button = $GridContainer/boton_salir
@onready var reiniciar_escena: Button = $GridContainer/reiniciar_escena

func _ready() -> void:
	boton_salir.pressed.connect(salir)
	reiniciar_escena.pressed.connect(restart)

func salir():
	get_tree().quit()
func restart():
	get_tree().reload_current_scene()
