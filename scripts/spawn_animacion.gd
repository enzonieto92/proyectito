extends Control
@onready var inicio: TextureRect = $inicio
@onready var inicio_2: TextureRect = $inicio2

func _ready() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(inicio, "position:y", -648,  3.0)
	tween.tween_property(inicio_2, "position:y", 648,  3.0)
	tween.chain().tween_callback(self.queue_free)
