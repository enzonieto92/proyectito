extends Node3D


func _ready() -> void:
	var velocidad = randf_range(1.0, 2.0)
	var tween = create_tween().set_loops()
	tween.tween_method(
		func(r): rotation.z = r,
		0.0,
		TAU,
		velocidad
	)
