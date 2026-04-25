extends Node3D


func _ready() -> void:
	get_viewport().grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
