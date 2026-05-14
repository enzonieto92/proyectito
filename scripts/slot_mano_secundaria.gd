class_name SecundarySlot extends slot_base

@onready var color_rect_2: ColorRect = $ColorRect2
@onready var sprite_secundaria: Sprite3D = get_tree().get_first_node_in_group("sprite_secundaria")
@onready var sonido_antorcha: AudioStreamPlayer3D = get_tree().get_first_node_in_group("antorcha_equipable")
func get_color_rect() -> ColorRect: return color_rect_2
func get_sprite() -> Sprite3D: return sprite_secundaria

func acepta_item(nuevo_item) -> bool:
	return nuevo_item is Antorcha or nuevo_item is Escudo

func aplicar_stats(jugador, nuevo_item) -> void:
	jugador.secundaria = nuevo_item
	jugador.armadura_total = jugador.armadura + nuevo_item.armadura
	if nuevo_item is Antorcha:
		sonido_antorcha.play()
		jugador.get_node("pivote_secundaria/posicion_secundaria/luz_antorcha").visible = true

func quitar_stats(jugador) -> void:
	if jugador.secundaria is Antorcha:
		sonido_antorcha.stop()
		jugador.get_node("pivote_secundaria/posicion_secundaria/luz_antorcha").visible = false
	jugador.secundaria = null
	jugador.armadura_total = jugador.armadura

func get_drag_flags() -> Dictionary:
	return {"desde_weapon_slot": false, "desde_secundary_slot": true, "secundary_slot_ref": self}

func _get_stat_actual(jugador) -> int:
	return jugador.armadura

func _restaurar_stat(jugador) -> void:
	jugador.armadura_total = _stat_antes_drag

func _restar_stat_drag(jugador) -> void:
	jugador.armadura_total -= _item_en_drag.armadura
