extends RichTextLabel

@export var chars_per_second: float = 15.0
var tween_actual : Tween = null

func show_text(new_text: String):
	text = new_text
	visible_characters = 40

func ocultar():
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	text = ""
	visible_characters = 0
	visible = false
