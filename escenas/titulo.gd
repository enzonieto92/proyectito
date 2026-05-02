extends Label

func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 3.0)
