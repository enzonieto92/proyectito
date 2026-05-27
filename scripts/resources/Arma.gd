extends Item

class_name Arma

@export var damage: Vector2
@export var armadura: float
@export var gasto_stamina: float
@export var durabilidad: int
@export var weapon_size: float
enum TipoArma { ESPADA, LANZA, MAZA, DAGA }

@export var tipo: TipoArma = TipoArma.ESPADA
