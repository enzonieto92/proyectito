extends CharacterBody3D

@onready var player: CharacterBody3D = $"../player"

var mat
var max_frames := 3
var speed := 3.0
var attack_range := 2.0

func _physics_process(delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	# Add the gravity.W
	velocity += get_gravity() * delta
	if dist < attack_range:
		attack_behavior()
	else:
		chase_behavior()
	# Rotación solo en Y (evita que el plano se incline)
	var target = player.global_position
	target.y = 0
	look_at(target)
	move_and_slide()

func chase_behavior():
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func attack_behavior():
	velocity = Vector3.ZERO
