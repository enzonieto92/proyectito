extends Node3D
var target 
func _ready() -> void:
	target = get_tree().get_first_node_in_group("jugador")
func _process(_delta: float) -> void:
	look_at(target.position)
	rotation.x = 0
	rotation.z = 0
