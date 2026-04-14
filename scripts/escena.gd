extends Node3D

func _ready() -> void:
	get_viewport().grab_focus()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
