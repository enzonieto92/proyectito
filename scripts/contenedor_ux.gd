extends SubViewportContainer

func _ready() -> void:
	grab_focus()

func _input(event: InputEvent) -> void:
	$SubViewport.push_input(event)

func _unhandled_input(event: InputEvent) -> void:
	$SubViewport.push_unhandled_input(event)
