extends Area3D

@export var velocidad := 1.0
@export var damage := Vector2(10, 15)
@export var sonido_travel: AudioStreamPlayer3D
@onready var sonido_impacto: AudioStreamPlayer3D = $sonido_impacto
var impactado = false

var direccion := Vector3.FORWARD

@onready var area_damage: Area3D = $area_de_damage      # nombre de tu nodo hijo

func _ready():
	sonido_travel =  $sonido_travel
	body_entered.connect(_on_hit)



func _process(delta):
	position += direccion * velocidad * delta

func _on_hit(_body):
	if impactado:
		return
	impactado = true
	$Node3D.visible = false
	$Node3D2.visible = false
	$particulas.queue_free()
	$SpotLight3D.queue_free()
	set_process(false)
	set_deferred("monitoring", false)
	explotar()
	sonido_impacto.play()
	sonido_impacto.finished.connect(queue_free)
func explotar():
	for cuerpo in area_damage.get_overlapping_bodies():
		if not cuerpo.has_method("recibir_damage"):
			cuerpo = cuerpo.get_parent()
		if cuerpo.has_method("recibir_damage") and cuerpo.is_in_group("enemigos"):
			cuerpo.recibir_damage(damage, false)
