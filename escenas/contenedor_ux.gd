extends SubViewportContainer

@onready var sub_viewport = $SubViewport

func _ready() -> void:
	sub_viewport.size = Vector2i(320, 180)
	grab_focus()
