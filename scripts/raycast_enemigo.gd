extends RayCast3D

@onready var player: CharacterBody3D = $"../../player"
var attacking = false

func _process(_delta: float) -> void:
	look_at(player.position, Vector3.UP)
	
	rotation.x = 90
	if attacking:
		get_collider()
