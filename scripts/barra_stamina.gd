extends ProgressBar

@onready var jugador: CharacterBody3D = get_tree().get_first_node_in_group("jugador")

func _ready() -> void:
	max_value = jugador.stamina
	value = max_value
func _process(_delta: float) -> void:
	value = jugador.stamina
	if jugador.inventario_abierto:
		visible = false
	else:
		visible = true
