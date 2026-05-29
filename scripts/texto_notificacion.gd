extends RichTextLabel

@export var chars_per_second: float = 15.0
var tween_actual : Tween = null

func show_text(new_text: String):
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	visible = true
	modulate.a = 1.0
	text = new_text
	visible_characters = 200
	tween_actual = create_tween()
	tween_actual.tween_interval(2.0)
	tween_actual.tween_property(self, "modulate:a", 0.0, 1.0)
	tween_actual.tween_callback(ocultar)

func ocultar():
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	text = ""
	visible_characters = 0
	visible = false
