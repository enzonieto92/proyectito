extends Control

@onready var titulo: Label = $titulo
@onready var sonido_enter: AudioStreamPlayer = $"../../sonido_enter"
@onready var musica_ambiente: AudioStreamPlayer = $"../../musica_ambiente"
@onready var label: Label = $Label
@onready var inicio: TextureRect = $"../inicio"
@onready var inicio_2: TextureRect = $"../inicio2"


@export var alpha_speed = 3.0
var elapsed := 0.0
var _cambiando_escena := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 2)

func _process(delta: float) -> void:
	elapsed += delta
	label.modulate.a = 0.5 + 0.5 * sin(elapsed * alpha_speed)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		get_tree().quit()
	if Input.is_action_just_pressed("enter") and not _cambiando_escena:
		_cambiando_escena = true
		sonido_enter.play()
		ResourceLoader.load_threaded_request("res://escenas/nivel_1.tscn")
		var tween = create_tween().set_parallel(true)
		tween.tween_property(inicio, "position:y", 0.0, 2)
		tween.tween_property(inicio_2, "position:y", 0.0, 2)
		tween.tween_property(musica_ambiente, "volume_db", -60.0, 4)
		await tween.finished
		var escena = ResourceLoader.load_threaded_get("res://escenas/nivel_1.tscn")
		get_tree().change_scene_to_packed(escena)
