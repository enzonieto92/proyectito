extends Node3D
@onready var camara_player: Camera3D = $"../camara_controller/camara_player"
@onready var jugador = $".."
var velocidad = 10.0
@export var velocidad_x: float = velocidad
@export var velocidad_y: float = velocidad

var target_y: float = 0.0

func _process(delta: float) -> void:
	target_y = lerp_angle(target_y, jugador.global_rotation.y, velocidad_y * delta)
	global_rotation.x = lerp(global_rotation.x, camara_player.global_rotation.x, velocidad_x * delta)
	global_rotation.y = target_y
