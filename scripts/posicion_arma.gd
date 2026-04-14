extends Node3D
@onready var camera_3d: Camera3D = $"../camara_player"



func _process(_delta: float) -> void:
	#fija el eje del arma con el eje de la camara
	rotation.x = camera_3d.rotation.x
