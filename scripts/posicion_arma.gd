extends Node3D
@onready var camara_player: Camera3D = $"../camara_controller/camara_player"
var _last_rotation: float = 0.0

func _process(_delta: float) -> void:
	var new_rot = camara_player.rotation.x
	if new_rot != _last_rotation:  # ✅ solo actualiza si cambió
		rotation.x = new_rot
		_last_rotation = new_rot
