extends Area3D

@export var player_entered = false

func _on_body_entered(body: Node3D) -> void:
	if body.name == "player":
		player_entered = true

func _on_body_exited(body: Node3D) -> void:
	if body.name == "player":
		player_entered = false
