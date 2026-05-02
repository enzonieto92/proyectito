extends Control
@onready var color_rect: ColorRect = $ColorRect
@onready var titulo: Label = $titulo

@onready var label: Label = $Label
@export var alpha_speed = 3.0  # velocidad del parpadeo
var elapsed := 0.0
func _process(delta: float) -> void:
	elapsed += delta
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color("3b3b3bff"), 2
	)
	tween.tween_property(self, "modulate:a",1.0,  2
	)
	label.modulate.a = 0.5 + 0.5 * sin(elapsed * alpha_speed) 
	titulo.modulate.a = lerp(0, 1, 0.5
	)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEvent:
		if Input.is_action_just_pressed("esc"):

			get_tree().quit()
		if Input.is_action_just_pressed("enter"):
			get_tree().change_scene_to_file("res://escenas/nivel_1.tscn")
