# animation_movement.gd
extends AnimationPlayer

@onready var player: CharacterBody3D = $".."

func _process(_delta):
	if player.inventario_abierto:
		if current_animation != "idle":
			play("idle")
		return
	
	if player.moving:
		if player.corriendo and player.puede_correr:
			if current_animation != "correr":
				play("correr")
		else:
			if current_animation != "caminar":
				play("caminar")
	else:
		if current_animation != "idle":
			play("idle")
