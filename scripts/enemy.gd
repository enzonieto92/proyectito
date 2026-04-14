extends CharacterBody3D

@onready var player: CharacterBody3D = $"../player"
@onready var sprite_enemy: AnimatedSprite3D = $sprite_enemy

var mat
var max_frames := 3
var speed := 2.5
@export var attack_range :=1.5


func _physics_process(delta: float) -> void:
	var dist = global_position.distance_to(player.global_position)
	var target_position = player.position
	target_position.y = global_position.y
	look_at(target_position)

	velocity += get_gravity() * delta
	if dist < attack_range:
		attack_behavior()
	else:
		chase_behavior()
	move_and_slide()
func chase_behavior():
	var dir = (player.global_position - global_position).normalized()
	sprite_enemy.play("enemy2")
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func attack_behavior():
	sprite_enemy.play("enemy2_attack")
	velocity = Vector3.ZERO
