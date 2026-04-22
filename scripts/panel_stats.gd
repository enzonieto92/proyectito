extends Panel

@onready var jugador: CharacterBody3D = get_tree().get_first_node_in_group("jugador")
var vida : int
var damage : Vector2
var armadura : int
@onready var label_vida: Label = $label_vida
@onready var label_armadura: Label = $label_armadura
@onready var label_damage: Label = $label_damage


func _ready() -> void:
	vida = int(jugador.vida)
	damage = jugador.total_damage
	armadura = int(jugador.armadura)
func _process(_delta: float) -> void:
	vida = int(jugador.vida)
	damage  = jugador.total_damage
	armadura = int(jugador.armadura)
	label_vida.text = "VIDA " +str(vida)
	label_armadura.text = "ARMADURA " +str(armadura)
	label_damage.text = "DAÑO " + str(int(damage.x))+"-" + str(int(damage.y))
