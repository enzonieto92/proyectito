extends CharacterBody3D

@onready var player: CharacterBody3D = $"../player"
@onready var sprite_enemy: AnimatedSprite3D = $sprite_enemy
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const ESPADA_GOLPE = preload("uid://1om5ecjw4tsm")

var speed := 2.5

@export var atacando : bool = false
@export var vida : float 
@export var attack_range : float
@export var animation_vector : Vector3

@export var max_damage : float
@export var min_damage : float

@export var salto = false

var _en_cooldown := false
var _atacando_cooldown := false
var damage : int
var attack_dir := Vector3.ZERO   # 🔥 dirección fija del ataque

func _physics_process(delta: float) -> void:
	if vida <= 0.0:
		dying_behavior()
		return

	var dist = global_position.distance_to(player.global_position)

	# 🔥 SOLO rotar si NO está atacando
	if not _atacando_cooldown:
		var target_position = player.position
		target_position.y = global_position.y

		var dir = (target_position - global_position).normalized()
		dir.y = 0

		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)

	# gravedad siempre
	velocity += get_gravity() * delta

	if _atacando_cooldown:

		# 🔥 usar dirección FIJA (no tracking en el aire)
		velocity.x = attack_dir.x * animation_vector.z
		velocity.z = attack_dir.z * animation_vector.z

		# 🔥 impulso vertical controlado por animación
		if salto:
			velocity.y = animation_vector.y
			salto = false

	elif dist < attack_range:
		attack_behavior()
		damage = int(randf_range(min_damage,max_damage))
	elif not _en_cooldown:
		chase_behavior()

	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()


func recibir_damage(_damage):
	var calcular_damage = int(randf_range(_damage.x, _damage.y))
	print (calcular_damage)
	vida -= calcular_damage
	
	var sonido = AudioStreamPlayer.new()
	sonido.stream = ESPADA_GOLPE
	add_child(sonido)          # ← agregarlo al árbol
	sonido.play()
	sonido.finished.connect(sonido.queue_free) 


func chase_behavior():
	var dir = (player.global_position - global_position).normalized()
	animation_player.play("chase")

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed


func dying_behavior():
	animation_player.play("dying")
	await animation_player.animation_finished
	queue_free()


func attack_behavior():
	if _atacando_cooldown:
		return

	_atacando_cooldown = true

	# 🔥 fijar dirección UNA VEZ
	attack_dir = (player.global_position - global_position).normalized()
	attack_dir.y = 0

	animation_player.play("attack")

	await animation_player.animation_finished

	# limpiar
	animation_vector = Vector3.ZERO

	_en_cooldown = true
	animation_player.play("chase")

	await get_tree().create_timer(1.0).timeout

	_en_cooldown = false
	_atacando_cooldown = false
