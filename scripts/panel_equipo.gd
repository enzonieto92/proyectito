extends Panel

func _ready():
	get_tree().get_first_node_in_group("jugador").inventario_abierto_changed.connect(_on_inventario_changed)

func _on_inventario_changed(abierto: bool):
	if abierto:
		print ("modificando alfa")
		modulate.a = 0
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 1.0, .3)
	else:
		modulate.a = 1
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, .3)
