extends Node3D
@export var damage : Vector2
@export var activador : Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var trampa_activada = false
var ya_golpeo := false

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animacion_terminada)

func _on_animacion_terminada(_anim_name):
	ya_golpeo = false
	trampa_activada = false

func _process(_delta: float) -> void:
	if activador == null:
		return
	if activador.activado and !trampa_activada:
		trampa_activada = true
		animation_player.play("puaAction")


func _on_area_colision_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador") or body.is_in_group("enemigos")  and not ya_golpeo:
		ya_golpeo = true
		body.recibir_damage(damage, true)
