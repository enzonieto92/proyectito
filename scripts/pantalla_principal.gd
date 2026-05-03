extends Control

@onready var titulo: Label = $titulo

@onready var label: Label = $Label
@onready var inicio: ColorRect = $"../inicio"
@export var alpha_speed = 3.0  # velocidad del parpadeo
var elapsed := 0.0
func _process(delta: float) -> void:
	elapsed += delta
	var tween = create_tween()

	
	tween.tween_property(self, "modulate:a",1.0,  2
	)
	label.modulate.a = 0.5 + 0.5 * sin(elapsed * alpha_speed) 
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEvent:
		if Input.is_action_just_pressed("esc"):

			get_tree().quit()
		if Input.is_action_just_pressed("enter"):
			var tween = create_tween()
			tween.tween_property(inicio, "modulate:a", 1.0, 3)
			tween.tween_callback(Callable(get_tree(), "change_scene_to_file")
	.bind("res://escenas/nivel_1.tscn"))
			
