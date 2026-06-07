
extends RichTextLabel

var _tiempo : float = 0
@export var chars_per_second: float = 15.0
var tween_actual : Tween = null
func _process(delta: float) -> void:
	if visible:
		_tiempo += delta
		modulate.a = 0.5 + 0.5 * sin(_tiempo * 3)

var _tab_mostrado: bool = false

func show_text(new_text: String, delay):
	if new_text == "Presiona (TAB)":
		if _tab_mostrado:
			return
		_tab_mostrado = true
	await get_tree().create_timer(delay).timeout
	visible = true
	modulate.a = 0.0
	text = new_text
	visible_characters = 200
func ocultar():
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	visible_characters = 0
	visible = false
