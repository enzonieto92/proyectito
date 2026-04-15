extends Resource
class_name Item

@export var id: String
@export var nombre: String
@export var icono: CompressedTexture2D
@export var textura: CompressedTexture2D
@export var descripcion: String = ""

@export var damage: float
@export var weapon_size: float    

# tamaño en la grilla (ej: 2x2)
@export var size: Vector2i = Vector2i(1, 1)

@export var stackable: bool = false
@export var max_stack: int = 1


enum Tipo {
	CONSUMIBLE,
	ARMA,
	EQUIPO,
	LLAVE,
	MISC
}

@export var tipo: Tipo = Tipo.MISC


# -----------------------------
# DATOS DE RUNTIME (NO EXPORTAR)
# -----------------------------

var grid_pos: Vector2i = Vector2i(-1, -1)
var cantidad: int = 1
var visual_node = null
var visual_bg = null
