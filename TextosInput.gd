extends Node
const GLIFOS_MANDO = {
	"interactuar": "Cuadrado",   # o "X" según si es Xbox/PlayStation
	"saltar": "X",
	"correr": "Círculo",
	"agacharse": "R3",
	"inventario": "Options",     # ajustá al botón real que le asignaste en el Input Map
	"zoom": "L2",                # ídem
	"lanzar_hechizo": "R1",      # ídem
}
const GLIFOS_TECLADO = {
	"interactuar": "E",
	"saltar": "Espacio",
	"correr": "Shift",
	"agacharse": "Ctrl",
	"inventario": "TAB",
	"zoom": "Click derecho",     # ajustá si es otra tecla/botón
	"lanzar_hechizo": "Q",       # ajustá si es otra tecla
}
func obtener_texto_accion(accion: String) -> String:
	if InputManager.dispositivo_actual == InputManager.Dispositivo.MANDO:
		return GLIFOS_MANDO.get(accion, accion)
	else:
		return GLIFOS_TECLADO.get(accion, accion)

func obtener_texto_movimiento() -> String:
	if InputManager.dispositivo_actual == InputManager.Dispositivo.MANDO:
		return "Usa el stick izquierdo para moverte"
	else:
		return "Usa WASD para moverte"
