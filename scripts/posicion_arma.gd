extends Node3D
@onready var camara_player: Camera3D = $"../camara_controller/camara_player"



func _process(_delta: float) -> void:
	#fija el eje del arma con el eje de la camara
	rotation.x = camara_player.rotation.x
