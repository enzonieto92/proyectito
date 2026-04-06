extends RichTextLabel

@export var chars_per_second: float = 15.0
var tween_actual : Tween = null

func show_text(new_text: String):
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	text = new_text
	visible_characters = 0
	var total = text.length()
	var duration = total / chars_per_second
	tween_actual = create_tween()
	tween_actual.tween_property(self, "visible_characters", total, duration)

func stop_text():
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	tween_actual = null
	visible_characters = 0
	text = ""
	visible = false
