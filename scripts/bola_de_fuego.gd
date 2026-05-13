extends Area3D

@export var velocidad := 1.0
@export var damage := Vector2(10, 15)


var direccion := Vector3.FORWARD

@onready var area_damage: Area3D = $area_de_damage      # nombre de tu nodo hijo

func _ready():
	body_entered.connect(_on_hit)



func _process(delta):
	position += direccion * velocidad * delta

func _on_hit(body):
	explotar()

func explotar():
	for cuerpo in area_damage.get_overlapping_bodies():
		if not cuerpo.has_method("recibir_damage"):
			cuerpo = cuerpo.get_parent()
		if cuerpo.has_method("recibir_damage"):
			cuerpo.recibir_damage(damage)
	queue_free()
