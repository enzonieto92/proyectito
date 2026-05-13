extends Area3D  # o AnimatableBody3D

@export var velocidad := 1.0
var direccion := Vector3.FORWARD


func _ready():
	rotation_degrees.y = 0
func _process(delta):
	position += direccion * velocidad * delta
func _on_hit(body):
	if body.has_method("recibir_damage"):
		body.recibir_damage(10)
	queue_free()
