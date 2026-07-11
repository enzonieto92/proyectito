extends CharacterBody3D
@export var knockback_force := 8.0
@export var knockback_lift := 1.5
@export var knockback_duration := 0.15
@export var stun_duration := 0.3
var _en_knockback := false
var _knockback_timer := 0.0
var knockback_velocity := Vector3.ZERO
var _en_stun := false
var _stun_timer := 0.0

const ESPADA_GOLPE = preload("uid://1om5ecjw4tsm")
var  SONIDO_ENEMIGO_PASIVO = preload("uid://cjv6cjh0wdmoo")
const SONIDO_ENEMIGO = preload("uid://dehsfh1pliac7")
const PAN = preload("uid://dni0ouuswkjrm")
const PEZ = preload("uid://d4gw3nu3068wh")
const SONIDO_MUERTE = preload("res://sonido/muerte_guardia.mp3")
@onready var colision_muerto: CollisionShape3D = $colision_muerto
var _agregando := false  
@onready var player: CharacterBody3D = $"../../player"
@onready var sprite_enemy: AnimatedSprite3D = $sprite_enemy
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sonido_enemigo: AudioStreamPlayer3D = $sonido_enemigo
@onready var raycast_vision: RayCast3D = $raycast_vision
@onready var sonido_golpe: AudioStreamPlayer = $sonido_golpe
@onready var raycast_enemigo: RayCast3D = $raycast_enemigo

@export var atacando: bool = false
@export var vida: float
@export var attack_range: float
@export var animation_vector: Vector3
@export var max_damage: float
@export var min_damage: float
@export var salto = false
var recibio_damage : bool = false
var item
var avistado = false
var speed := 2.5
var player_entered_area: bool = false
var _en_cooldown := false
var _atacando_cooldown := false
var damage: int
var attack_dir := Vector3.ZERO
var died = false
var dying_started = false
var _puerta_cooldown = false
var vision_timer := 0.0
var vision_interval := 0.3
var repath_timer := 0.0
var repath_interval := 0.5

var hit_applied := false
func puede_interactuar() -> bool:
	return died and item != null 
func interactuar(_player):
	if _agregando:
		return
	_agregando = true
	_agregar.call_deferred(_player)
func _ready() -> void:
	sonido_enemigo.stream = SONIDO_ENEMIGO_PASIVO
	sonido_enemigo.play()

	raycast_vision.target_position = Vector3(0, 0, -1)
	raycast_vision.force_raycast_update()

	var _precarga = SONIDO_ENEMIGO

func dropear_item():
	if Calculos.chance(50):
		item = PEZ.duplicate()
	else:
		item = PAN.duplicate()
func _physics_process(delta: float) -> void:
	if vida <= 0.0:
		dying_behavior()
		return

	velocity += get_gravity() * delta

	if _en_knockback:
		_knockback_timer -= delta
		var t = clamp(_knockback_timer / knockback_duration, 0.0, 1.0)
		var ease_t = t * t
		velocity.x = knockback_velocity.x * ease_t
		velocity.z = knockback_velocity.z * ease_t
		if _knockback_timer <= 0.0:
			_en_knockback = false
			velocity.x = 0
			velocity.z = 0
		move_and_slide()
		return

	if _en_stun:
		_stun_timer -= delta
		velocity.x = 0
		velocity.z = 0
		if _stun_timer <= 0.0:
			_en_stun = false
		move_and_slide()
		return

	var dist = global_position.distance_to(player.global_position)

	if not avistado and player_entered_area:
		vision_timer -= delta
		if vision_timer <= 0.0:
			vision_timer = vision_interval
			rastrear()

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
	elif (avistado and not _en_cooldown) or recibio_damage:
		look_at_target()
		chequear_puerta_en_camino()
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


func recibir_damage(_damage, _reletizacion) -> void:
	recibio_damage = true
	vida -= int(randf_range(_damage.x, _damage.y))
	sonido_golpe.stream = ESPADA_GOLPE
	sonido_golpe.play()
	_interrumpir_y_knockback()

func _interrumpir_y_knockback() -> void:
	if vida <= 0.0:
		return  # si ya murió con este golpe, dejá que dying_behavior tome el control

	# Cortar la animación de ataque DE VERDAD, no solo el callback
	if animation_player.animation_finished.is_connected(_on_attack_finished):
		animation_player.animation_finished.disconnect(_on_attack_finished)
	animation_player.stop()

	_atacando_cooldown = false
	_en_cooldown = false
	atacando = false
	hit_applied = false

	# Dirección desde el jugador hacia el enemigo = "alejarse de donde vino el golpe"
	var knock_dir = (global_position - player.global_position)
	knock_dir.y = 0
	if knock_dir.length() > 0.001:
		knock_dir = knock_dir.normalized()
	else:
		knock_dir = -transform.basis.z  # fallback por si están superpuestos

	knockback_velocity = knock_dir * knockback_force
	_en_knockback = true
	_knockback_timer = knockback_duration
	velocity.y = knockback_lift

	# Después del knockback, se queda "aturdido" un ratito antes de volver a atacar/perseguir
	_en_stun = true
	_stun_timer = knockback_duration + stun_duration

	#animation_player.play("hit")

func attack_behavior() -> void:
	if _atacando_cooldown:
		return

	_atacando_cooldown = true
	hit_applied = false

	damage = int(randf_range(min_damage, max_damage))
	attack_dir = (player.global_position - global_position).normalized()
	attack_dir.y = 0

	animation_player.play("attack")
	if animation_player.animation_finished.is_connected(_on_attack_finished):
		animation_player.animation_finished.disconnect(_on_attack_finished)
	animation_player.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)


func aplicar_golpe() -> void:
	if hit_applied:
		return
	hit_applied = true
	if global_position.distance_to(player.global_position) <= attack_range:
		player.recibir_damage(Vector2(min_damage, max_damage), true)
		raycast_enemigo.intentar_golpe()  


func _on_attack_finished(_anim: String) -> void:
	animation_vector = Vector3.ZERO
	_en_cooldown = true
	animation_player.play("idle")
	get_tree().create_timer(1.0).timeout.connect(_on_cooldown_finished, CONNECT_ONE_SHOT)


func _on_cooldown_finished() -> void:
	if vida <= 0.0:
		return
	_en_cooldown = false
	_atacando_cooldown = false
	raycast_enemigo.ya_golpeo = false # ← nombre del nodo que tengas

func _agregar(_player) -> void:
	if item == null:
		_agregando = false
		return

	var item_a_agregar = item
	item = null

	if await _player.inventario_controller.agregar_item(item_a_agregar):
		pass
	var area = get_node_or_null("area_deteccion")
	area.queue_free()
	_agregando = false
func dying_behavior() -> void:
	if dying_started:
		return
	raycast_enemigo.queue_free()
	
	if is_on_floor():
		dying_started = true
		died = true
		if Calculos.chance(100):
			dropear_item()
		else:
			pass

		sonido_enemigo.stream = SONIDO_MUERTE
		sonido_enemigo.volume_db = -40.0
		sonido_enemigo.pitch_scale = 0.6
		sonido_enemigo.play()

		animation_player.stop()
		if animation_player.animation_finished.is_connected(_on_attack_finished):
			animation_player.animation_finished.disconnect(_on_attack_finished)
		if animation_player.animation_finished.is_connected(_on_dying_finished):
			animation_player.animation_finished.disconnect(_on_dying_finished)

		animation_player.play("dying")
		animation_player.animation_finished.connect(_on_dying_finished, CONNECT_ONE_SHOT)
	else:
		velocity += get_gravity()
		move_and_slide()


func _on_dying_finished(_anim: String) -> void:
	animation_player.pause()
	var colision = get_node("coll_guardia")
	colision.disabled = true
	colision_muerto.disabled = false

func rastrear() -> void:
	raycast_vision.target_position = to_local(player.global_position)
	raycast_vision.force_raycast_update()

	if not raycast_vision.is_colliding():
		_confirmar_avistado()
		return

	var coll = raycast_vision.get_collider()

	if coll.is_in_group("jugador"):
		_confirmar_avistado()
		return

	if coll.is_in_group("puertas") and not _puerta_cooldown:  # ← agregado
		golpear_puerta(coll)

func chequear_puerta_en_camino() -> void:
	if _puerta_cooldown:  # ← salir antes del raycast incluso
		return

	raycast_vision.target_position = to_local(player.global_position)
	raycast_vision.force_raycast_update()

	if not raycast_vision.is_colliding():
		return
	var coll = raycast_vision.get_collider()
	if coll.is_in_group("puertas"):
		golpear_puerta(coll)

func golpear_puerta(coll: Node) -> void:
	if _puerta_cooldown:
		return

	_puerta_cooldown = true
	get_tree().create_timer(2.0).timeout.connect(
		func():
			if not is_instance_valid(coll):
				_puerta_cooldown = false
				return
			damage = int(randf_range(min_damage, max_damage))
			coll.resistencia -= damage
			coll.hit_puerta()
			if coll.resistencia <= 0:
				coll.call_deferred("romper")
				_puerta_cooldown = false
			else:
				get_tree().create_timer(2.0).timeout.connect(
					func(): _puerta_cooldown = false
				)
	)
func _confirmar_avistado() -> void:
	if not avistado:
		avistado = true
		sonido_enemigo.stream = SONIDO_ENEMIGO
		sonido_enemigo.volume_db = -30.0
		sonido_enemigo.play()


func _on_area_deteccion_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered_area = true


func _on_area_deteccion_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered_area = false
