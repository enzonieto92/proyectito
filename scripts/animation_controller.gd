extends Node

@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var player: CharacterBody3D = $".."

func _ready():
	animation_player.play("idle")

func _process(_delta: float) -> void:
	if Input.is_action_pressed("atacar"):
		if animation_player.current_animation != "atacar":
			animation_player.play("atacar")
	elif player.moving:
		if player.corriendo:
			if animation_player.current_animation != "correr":
				animation_player.play("correr")
		else:
			animation_player.play("caminar")
		
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
