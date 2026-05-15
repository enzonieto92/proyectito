extends Node3D
var interruptor
@onready var animacion: AnimationPlayer = $animacion

@onready var area_3d: Area3D = $hacha/Area3D

@onready var hacha: MeshInstance3D = $hacha
var damage = Vector2(17, 20)
var ya_golpeo := false

func _ready() -> void:
	interruptor = get_tree().get_first_node_in_group("interruptor_hacha")
	animacion.animation_finished.connect(_on_animacion_terminada)

func _on_animacion_terminada(_anim_name):
	ya_golpeo = false

func _process(_delta: float) -> void:
	if interruptor.activado:
		if !animacion.is_playing():
			animacion.play("hachaAction")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("jugador") or body.is_in_group("enemigos")) and not ya_golpeo:
		ya_golpeo = true
		var _damage = int(randf_range(damage.x, damage.y))
		body.recibir_damage(_damage, true)
