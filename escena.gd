extends Node3D
@onready var mesh = $player/Camera3D/MeshInstance3D2
var mat
func _ready() -> void:
	get_viewport().grab_focus()
	mat = mesh.get_active_material(0).duplicate()
	mesh.material_override = mat
	var tween = create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 5.0)
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
