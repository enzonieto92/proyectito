extends Resource
class_name Item

@export var id: String
@export var nombre: String
@export var icono: CompressedTexture2D
@export var descripcion: String = ""

# stackeo (ya listo para futuro)
@export var stackable: bool = false
@export var max_stack: int = 1

# opcional: tipo de item (te va a servir después)
enum Tipo {
	CONSUMIBLE,
	EQUIPO,
	LLAVE,
	MISC
}

@export var tipo: Tipo = Tipo.MISC
