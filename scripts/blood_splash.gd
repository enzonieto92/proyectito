extends TextureRect

@export var speed = 2.0
@export var amplitude = 0.40
@export var base_scale = 1.0
@export var alpha_speed = 3.0  # velocidad del parpadeo
var elapsed := 0.0

func _ready():
	pivot_offset = size / 2

func _process(delta):
	elapsed += delta
	var s = base_scale + amplitude * sin(elapsed * speed)
	scale = Vector2(s, s)
	modulate.a = 0.5 + 0.5 * sin(elapsed * alpha_speed)  # ✅ oscila entre 0 y 1
