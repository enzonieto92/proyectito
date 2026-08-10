extends CharacterBody3D
@export var knockback_force := 8
@export var knockback_lift := 1.5  # cuánto se eleva al recibir el golpe
@export var knockback_duration := 0.2
var _en_knockback := false
var _knockback_timer := 0.0
var knockback_velocity := Vector3.ZERO
@export var stun_duration := 0.3
var _en_stun := false
var _stun_timer := 0.0
const ESPADA_GOLPE = preload("uid://1om5ecjw4tsm")
const SONIDO_ENEMIGO_PASIVO = preload("uid://cjv6cjh0wdmoo")
const SONIDO_ENEMIGO = preload("uid://dehsfh1pliac7")
const SONIDO_MUERTE = preload("res://sonido/dying_enemigo.mp3") 
const PAN = preload("uid://dni0ouuswkjrm")
const PEZ = preload("uid://d4gw3nu3068wh")
@onready var colision: CollisionShape3D = $CollisionShape3D
@onready var area: CollisionShape3D = $area_deteccion/CollisionShape3D
@onready var colision_muerto: CollisionShape3D = $colision_muerto
@onready var raycast_enemigo: RayCast3D = $raycast_enemigo

@onready var player = get_tree().get_first_node_in_group("jugador")
@onready var sprite_enemy: AnimatedSprite3D = $sprite_enemy
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sonido_enemigo: AudioStreamPlayer3D = $sonido_enemigo
@onready var sonido_golpe: AudioStreamPlayer = $sonido_golpe 
@export var atacando: bool = false
@export var vida: float
@export var attack_range: float
@export var animation_vector: Vector3
@export var max_damage: float
@export var min_damage: float
@export var salto = false

var recibio_damage: bool = false
var _agregando := false  
var item
var speed := 2.5
var player_entered: bool = false
var _en_cooldown := false
var _atacando_cooldown := false
var damage: int
var attack_dir := Vector3.ZERO
var died = false
var repath_timer := 0.0
var repath_interval := 0.5

func _ready() -> void:
	sonido_enemigo.stream = SONIDO_ENEMIGO_PASIVO
	sonido_enemigo.play()
	randomize()
	colision.shape = colision.shape.duplicate()
func _physics_process(delta: float) -> void:
	if vida <= 0.0:
		dying_behavior()
		return

	velocity += get_gravity() * delta

	if _en_knockback:
		_knockback_timer -= delta
		var t = clamp(_knockback_timer / knockback_duration, 0.0, 1.0)
		var ease_t = t * t  # frena progresivamente, no de golpe
		velocity.x = knockback_velocity.x * ease_t
		velocity.z = knockback_velocity.z * ease_t
		if _knockback_timer <= 0.0:
			_en_knockback = false
			velocity.x = 0
			velocity.z = 0
		move_and_slide()
		_resolver_colision_jugador()
		return

	if _en_stun:
		_stun_timer -= delta
		velocity.x = 0
		velocity.z = 0
		if _stun_timer <= 0.0:
			_en_stun = false
		move_and_slide()
		_resolver_colision_jugador()
		return

	var dist = global_position.distance_to(player.global_position)

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
	elif (player_entered and not _en_cooldown) or recibio_damage:
		look_at_target()
		chase_behavior()
	else:
		velocity.x = 0
		velocity.z = 0

	move_and_slide()
	_resolver_colision_jugador()
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

func recibir_damage(_damage, _relentizacion) -> void:
	recibio_damage = true
	vida -= int(randf_range(_damage.x, _damage.y))
	sonido_golpe.stream = ESPADA_GOLPE
	sonido_golpe.play()
	_interrumpir_y_knockback()
func _interrumpir_y_knockback() -> void:
	if animation_player.animation_finished.is_connected(_on_attack_finished):
		animation_player.animation_finished.disconnect(_on_attack_finished)
	animation_player.stop()
	_atacando_cooldown = false
	_en_cooldown = false
	atacando = false

	var knock_dir = (global_position - player.global_position)
	knock_dir.y = 0
	if knock_dir.length() > 0.001:
		knock_dir = knock_dir.normalized()
	else:
		knock_dir = -transform.basis.z

	knockback_velocity = knock_dir * knockback_force
	_en_knockback = true
	_knockback_timer = knockback_duration
	velocity.y = knockback_lift  # ← el "salto" del knockback

	_en_stun = true
	_stun_timer = knockback_duration + stun_duration

	#animation_player.play("hit")
func dropear_item():
	if Calculos.chance(50):
		item = PEZ.duplicate()
	else:
		item = PAN.duplicate()
func dying_behavior() -> void:
	if is_on_floor() and !died:
		died = true  # ✅ primero para evitar doble ejecución
		if Calculos.chance(100):
			dropear_item()
		else:
			pass
		sonido_enemigo.stream = SONIDO_MUERTE  # ✅ preload
		sonido_enemigo.pitch_scale = 2.0
		sonido_enemigo.play()
		animation_player.play("dying")
		animation_player.animation_finished.connect(_on_dying_finished, CONNECT_ONE_SHOT)
		nav_agent.queue_free()
	elif !died:
		velocity += get_gravity()
		move_and_slide()
var _ya_murio := false
func _on_dying_finished(_anim: String) -> void:
	if _ya_murio:
		return
	_ya_murio = true
	animation_player.pause()
	if is_instance_valid(sonido_enemigo):
		sonido_enemigo.queue_free()
	colision.disabled = true
	colision_muerto.disabled = false
func puede_interactuar() -> bool:
	if died and item != null:
		return player_entered

	return false

func interactuar(_player):
	if _agregando:
		return
	_agregando = true
	_agregar.call_deferred(_player)
func _resolver_colision_jugador():
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var cuerpo = col.get_collider()
		if cuerpo.is_in_group("jugador"):
			var direccion = (global_position - cuerpo.global_position).normalized()
			# si está muy encima, forzar separación lateral fuerte
			if direccion.y > 0.5:
				direccion.y = 0
				direccion = direccion.normalized()
				global_position += direccion * 0.1  # ← mover directamente la posición
			velocity.x += direccion.x * 8.0
			velocity.z += direccion.z * 8.0
func _agregar(_player) -> void:
	if item == null:
		_agregando = false
		return

	var item_a_agregar = item
	item = null

	if await _player.inventario_controller.agregar_item(item_a_agregar):
		pass
	if is_instance_valid(area):  # ← mismo fix acá
		area.queue_free()
	_agregando = false

func attack_behavior() -> void:
	if _atacando_cooldown:
		return

	_atacando_cooldown = true
	damage = int(randf_range(min_damage, max_damage))
	attack_dir = (player.global_position - global_position).normalized()
	attack_dir.y = 0
	
	animation_player.play("attack")
	if animation_player.animation_finished.is_connected(_on_attack_finished):
		animation_player.animation_finished.disconnect(_on_attack_finished)
	animation_player.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
func _on_attack_finished(anim: String) -> void:
	if anim != "attack":
		return
	animation_vector = Vector3.ZERO
	_en_cooldown = true
	animation_player.play("chase")
	get_tree().create_timer(2.0).timeout.connect(_on_cooldown_finished, CONNECT_ONE_SHOT)
	
func _on_cooldown_finished() -> void:
	_en_cooldown = false
	_atacando_cooldown = false
	var raycast = get_node_or_null("raycast_enemigo")  # ajustá el nombre
	if raycast:
		raycast.ya_golpeo = false
func _on_area_deteccion_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		if !died:
			sonido_enemigo.stream = SONIDO_ENEMIGO
			sonido_enemigo.volume_db = -30.0
			sonido_enemigo.play()
		player_entered = true

func _on_area_deteccion_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered = false
