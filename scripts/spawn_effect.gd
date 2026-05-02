extends ColorRect
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 4.0)
	tween.tween_callback(queue_free) 
