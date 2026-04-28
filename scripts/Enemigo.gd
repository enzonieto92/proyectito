extends CharacterBody3D

@onready var player: CharacterBody3D = $"../player"
@onready var sprite_enemy: AnimatedSprite3D = $sprite_enemy
@onready var animation_player: AnimationPlayer = $AnimationPlayer
const ESPADA_GOLPE = preload("uid://1om5ecjw4tsm")
const SONIDO_ENEMIGO_PASIVO = preload("uid://dihjxs15viicy")
const SONIDO_ENEMIGO = preload("uid://7l0ge7qhpr1b")
@onready var sonido_enemigo: AudioStreamPlayer3D = $sonido_enemigo

var speed := 2.5
var player_entered_area: bool = false
@export var atacando: bool = false
@export var vida: float
@export var attack_range: float
@export var animation_vector: Vector3
@export var max_damage: float
@export var min_damage: float
@export var salto = false

var _en_cooldown := false
var _atacando_cooldown := false
var damage: int
var attack_dir := Vector3.ZERO
var died = false
# ── Patrulla ──────────────────────────────────────────────
enum EstadoPatrulla { AVANZANDO, ESPERANDO, GIRANDO }
var patrol_estado: EstadoPatrulla = EstadoPatrulla.AVANZANDO
var patrol_angulo_objetivo: float = 0.0
var patrol_timer: float = 0.0
var patrol_tiempo_avanzando: float = 0.0
const PATROL_MAX_TIEMPO := 3.0  # segundos máximo avanzando

const PATROL_SPEED      := 1.2   # más lento que al perseguir
const PATROL_ESPERA     := 1.5   # segundos parado entre giros
const PATROL_VEL_GIRO   := 2.0
# ─────────────────────────────────────────────────────────

func _ready() -> void:
	sonido_enemigo.stream = SONIDO_ENEMIGO_PASIVO
	sonido_enemigo.play()
	# Arranca mirando en una dirección aleatoria
	patrol_angulo_objetivo = randf_range(-PI, PI)
	rotation.y = patrol_angulo_objetivo

func _physics_process(delta: float) -> void:
	if vida <= 0.0:
		dying_behavior()
		return

	var dist = global_position.distance_to(player.global_position)
	velocity += get_gravity() * delta

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
		# Persiguiendo — retoma rotación hacia el jugador
		look_at_target()
		chase_behavior()

	else:
		# Sin jugador cerca → patrullar
		_patrol_process(delta)

	move_and_slide()

# ── Lógica de patrulla ────────────────────────────────────
func _patrol_process(delta: float) -> void:
	match patrol_estado:
		EstadoPatrulla.AVANZANDO:
			_patrol_avanzar()
		EstadoPatrulla.ESPERANDO:
			_patrol_esperar(delta)
		EstadoPatrulla.GIRANDO:
			_patrol_girar(delta)


func _patrol_avanzar() -> void:
	animation_player.play("chase")
	velocity.x = -transform.basis.z.x * PATROL_SPEED
	velocity.z = -transform.basis.z.z * PATROL_SPEED
	patrol_tiempo_avanzando += get_physics_process_delta_time()

	# Se traba si: choca con pared O lleva demasiado tiempo sin cambiar
	if is_on_wall() or patrol_tiempo_avanzando >= PATROL_MAX_TIEMPO:
		patrol_tiempo_avanzando = 0.0
		velocity.x = 0
		velocity.z = 0
		patrol_timer = PATROL_ESPERA
		patrol_estado = EstadoPatrulla.ESPERANDO

func _patrol_esperar(delta: float) -> void:
	animation_player.play("chase")
	velocity.x = 0
	velocity.z = 0
	patrol_timer -= delta
	if patrol_timer <= 0.0:
		# Opuesto a donde venía ± variación aleatoria
		patrol_angulo_objetivo = rotation.y + PI + randf_range(-PI / 3.0, PI / 3.0)
		patrol_estado = EstadoPatrulla.GIRANDO

func _patrol_girar(delta: float) -> void:
	var rotacion_destino := Basis(Vector3.UP, patrol_angulo_objetivo)
	transform.basis = transform.basis.slerp(rotacion_destino, PATROL_VEL_GIRO * delta)
	velocity.x = 0
	velocity.z = 0
	# Cuando está alineado, avanzar de nuevo
	var diferencia := transform.basis.z.angle_to(-rotacion_destino.z)
	if diferencia < 0.05:
		transform.basis = rotacion_destino
		patrol_estado = EstadoPatrulla.AVANZANDO
# ─────────────────────────────────────────────────────────

func look_at_target() -> void:
	var target_position = player.position
	target_position.y = global_position.y
	var dir = (target_position - global_position).normalized()
	dir.y = 0
	rotation.y = atan2(dir.x, dir.z)

func recibir_damage(_damage) -> void:
	vida -= int(randf_range(_damage.x, _damage.y))
	var sonido = AudioStreamPlayer.new()
	sonido.stream = ESPADA_GOLPE
	add_child(sonido)
	sonido.play()
	sonido.finished.connect(sonido.queue_free)

func chase_behavior() -> void:
	var dir = (player.global_position - global_position).normalized()
	animation_player.play("chase")
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

func dying_behavior() -> void:

	if is_on_floor() and !died:
		var area = get_node("area_deteccion")
		var colision = get_node("CollisionShape3D")
		if area.monitoring:
			colision.disabled = true
			area.monitoring = false
		var dying_sonido = load("res://sonido/dying_enemigo.mp3")
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
	await get_tree().create_timer(1.0).timeout
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
		patrol_estado = EstadoPatrulla.ESPERANDO
		patrol_timer = 0.5
		patrol_tiempo_avanzando = 0.0  # ← agregar esto
