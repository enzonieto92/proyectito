extends RichTextLabel

@export var chars_per_second: float = 40.0
var tween_actual: Tween = null
var tween_bg: Tween = null

func _ready():
	# asegurate de tener un StyleBoxFlat seteado en el theme override
	var style = get_theme_stylebox("normal").duplicate()
	add_theme_stylebox_override("normal", style)
	style.bg_color.a = 0.0

func _fade(target_alpha: float):
	if tween_bg != null and tween_bg.is_running():
		tween_bg.kill()
	var style = get_theme_stylebox("normal") as StyleBoxFlat
	tween_bg = create_tween()
	tween_bg.tween_method(func(a: float):
		style.bg_color.a = a
	, style.bg_color.a, target_alpha, 0.4)

func show_text(new_text: String):
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	text = new_text
	visible_characters = 0
	visible = true
	_fade(0.4)
	_mostrar_caracteres()

func stop_text():
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	tween_actual = null
	_fade(0.0)
	tween_bg.tween_callback(func():
		visible_characters = 0
		text = ""
		visible = false
	)

func _mostrar_caracteres():
	var total = text.length()
	if visible_characters >= total:
		return
	visible_characters += 1
	var char_actual = text[visible_characters - 1]
	var delay = 1.0 / chars_per_second
	if char_actual == ".":
		delay += 0.5
	elif char_actual == ",":
		delay += 0.3
	tween_actual = create_tween()
	tween_actual.tween_interval(delay)
	tween_actual.tween_callback(_mostrar_caracteres)

func mostrar_todo():
	visible_characters = -1
