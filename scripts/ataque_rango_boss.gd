extends Node3D
@export var damage : Vector2
@onready var area_3d: Area3D = $Area3D
@onready var tentaculos: AnimatedSprite3D = $tentaculos
var ya_golpeo = false
func _ready() -> void:
	await get_tree().create_timer(0.6).timeout
	area_3d.monitoring = true
func _process(_delta: float) -> void:
	await tentaculos.animation_finished
	queue_free()
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		if ya_golpeo:
			return
		body.recibir_damage(damage, true)
		ya_golpeo = true
