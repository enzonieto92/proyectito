extends CharacterBody3D

const ESPADA_GOLPE = preload("uid://1om5ecjw4tsm")
const SONIDO_ENEMIGO_PASIVO = preload("uid://cjv6cjh0wdmoo")
const SONIDO_ENEMIGO = preload("uid://dehsfh1pliac7")

@onready var player: CharacterBody3D = $"../player"
@onready var sprite_enemy: AnimatedSprite3D = $sprite_enemy
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sonido_enemigo: AudioStreamPlayer3D = $sonido_enemigo

@export var atacando: bool = false
@export var vida: float
@export var attack_range: float
@export var animation_vector: Vector3
@export var max_damage: float
@export var min_damage: float
@export var salto = false

var speed := 2.5
var player_entered_area: bool = false
var _en_cooldown := false
var _atacando_cooldown := false
var damage: int
var attack_dir := Vector3.ZERO
var died = false

# 🔧 control de pathfinding
var repath_timer := 0.0
var repath_interval := 0.5

func _ready() -> void:
	sonido_enemigo.stream = SONIDO_ENEMIGO_PASIVO
	sonido_enemigo.play()

func _physics_process(delta: float) -> void:
	if vida <= 0.0:
		dying_behavior()
		return

	var dist = global_position.distance_to(player.global_position)
	velocity += get_gravity() * delta

	# 🔥 actualizar destino cada cierto tiempo (no cada frame)
	repath_timer -= delta
	if repath_timer <= 0.0:
		nav_agent.target_position = player.global_position
		repath_timer = repath_interval

	if _atacando_cooldown:
		velocity.x = attack_dir.x * animation_vector.z
		velocity.z = attack_dir.z * animation_vector.z
		if salto:
			velocity.y = animation_vector.y
			salto = false

	elif dist < attack_range:
		attack_behavior()
		damage = int(randf_range(min_damage, max_damage))

	elif player_entered_area and not _en_cooldown:
		look_at_target()
		chase_behavior()

	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()

func look_at_target() -> void:
	var target_position = player.global_position
	target_position.y = global_position.y
	var dir = (target_position - global_position).normalized()
	if dir.length() > 0.001:
		transform.basis = Basis(Vector3.UP, atan2(dir.x, dir.z))

func chase_behavior() -> void:
	if nav_agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return

	var next_pos = nav_agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()

	animation_player.play("chase")
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func recibir_damage(_damage) -> void:
	vida -= int(randf_range(_damage.x, _damage.y))
	var sonido = AudioStreamPlayer.new()
	sonido.stream = ESPADA_GOLPE
	add_child(sonido)
	sonido.play()
	sonido.finished.connect(sonido.queue_free)

func dying_behavior() -> void:
	if is_on_floor() and !died:
		var area = get_node("area_deteccion")
		var colision = get_node("CollisionShape3D")

		if area.monitoring:
			colision.disabled = true
			area.monitoring = false

		var dying_sonido = load("res://sonido/muerte_guardia.mp3")
		var stream_enemigo = get_node("sonido_enemigo")
		stream_enemigo.stream = dying_sonido
		stream_enemigo.volume_db = 40.0
		stream_enemigo.pitch_scale = 2.0
		stream_enemigo.play()

		animation_player.play("dying")
		await animation_player.animation_finished
		animation_player.pause()

		area.queue_free()
		colision.queue_free()
		died = true

	elif !died:
		velocity += get_gravity()
		move_and_slide()

func attack_behavior() -> void:
	if _atacando_cooldown:
		return

	_atacando_cooldown = true
	attack_dir = (player.global_position - global_position).normalized()
	attack_dir.y = 0

	animation_player.play("attack")
	await animation_player.animation_finished

	animation_vector = Vector3.ZERO
	_en_cooldown = true

	animation_player.play("chase")
	await get_tree().create_timer(3.0).timeout

	_en_cooldown = false
	_atacando_cooldown = false

func _on_area_deteccion_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		sonido_enemigo.stream = SONIDO_ENEMIGO
		sonido_enemigo.volume_db = -30.0
		sonido_enemigo.play()
		player_entered_area = true

func _on_area_deteccion_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered_area = false
