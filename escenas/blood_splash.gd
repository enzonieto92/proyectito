extends TextureRect

@export var speed = 2.0
@export var amplitude = 0.40
@export var base_scale = 1.0

var elapsed := 0.0
func _ready():
	pivot_offset = size / 2  # centro del nodo

func _process(delta):
	elapsed += delta
	var s = base_scale + amplitude * sin(elapsed * speed)
	scale = Vector2(s, s)
