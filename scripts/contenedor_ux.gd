extends SubViewportContainer

@onready var sub_viewport = $SubViewport

func _ready() -> void:
	grab_focus()
