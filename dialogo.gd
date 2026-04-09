extends RichTextLabel

@export var chars_per_second: float = 20.0
var tween_actual : Tween = null

func show_text(new_text: String):
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	text = new_text
	visible_characters = 0
	_mostrar_caracteres()

func _mostrar_caracteres():
	var total = text.length()
	
	if visible_characters >= total:
		return
	
	visible_characters += 1
	
	var char_actual = text[visible_characters - 1]
	var delay = 1.0 / chars_per_second
	
	if char_actual == ".":
		delay += 0.5  # pausa extra en punto
	elif char_actual == ",":
		delay += 0.3 # pausa menor en coma, opcional
	
	tween_actual = create_tween()
	tween_actual.tween_interval(delay)
	tween_actual.tween_callback(_mostrar_caracteres)
func stop_text():
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	tween_actual = null
	visible_characters = 0
	text = ""
	visible = false
