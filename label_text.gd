extends RichTextLabel

@export var chars_per_second: float = 15.0
@onready var door = $"../../dungeon/pared con puerta/pivote/door"
@onready var door2 = $"../../dungeon/pared con puerta2/pivote/door"
@onready var raycast = $"../../player/Camera3D/raycast"

var puerta_actual = null

func _process(_delta):
	if puerta_actual == null:
		return
	if raycast.is_colliding():
		var golpeado = raycast.get_collider()
		if golpeado == puerta_actual or golpeado.get_parent() == puerta_actual:
			visible = true
			_actualizar_texto()
			return
	visible = false # solo ocultás si había puerta pero no la estás mirando
func _ready():
	door.player_entered.connect(_on_player_entered.bind(door))
	door.player_exited.connect(_on_player_exited)
	door2.player_entered.connect(_on_player_entered.bind(door2))
	door2.player_exited.connect(_on_player_exited)
	door.estado.connect(_on_estado_cambio)
	door2.estado.connect(_on_estado_cambio)


func _on_player_entered(puerta):
	puerta_actual = puerta
	visible = true
	_actualizar_texto()

func _on_player_exited():
	puerta_actual = null
	visible = false
	text = ""

func _on_estado_cambio():
	if puerta_actual != null:
		_actualizar_texto()

func _actualizar_texto():
	if puerta_actual.abierta:
		text = "(E) Cerrar"
	else:
		text = "(E) Abrir"
	visible_characters = -1  

var tween_actual : Tween = null

func show_text(new_text: String):
	if tween_actual != null and tween_actual.is_running():
		tween_actual.kill()
	text = new_text
	visible_characters = 0
	var total = text.length()
	var duration = total / chars_per_second
	tween_actual = create_tween()
	tween_actual.tween_property(self, "visible_characters", total, duration)
