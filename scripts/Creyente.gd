extends CharacterBody3D

const ESPADA_GOLPE = preload("uid://1om5ecjw4tsm")
const SONIDO_ENEMIGO_PASIVO = preload("uid://cjv6cjh0wdmoo")
const SONIDO_ENEMIGO = preload("uid://dehsfh1pliac7")
const SONIDO_MUERTE = preload("res://sonido/dying_enemigo.mp3") 
const PAN = preload("uid://dni0ouuswkjrm")
const PEZ = preload("uid://d4gw3nu3068wh")
@onready var colision: CollisionShape3D = $CollisionShape3D
@onready var area: CollisionShape3D = $area_deteccion/CollisionShape3D

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

	var dist = global_position.distance_to(player.global_position)
	velocity += get_gravity() * delta

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
		attack_behavior()  # ✅ damage movido adentro
	elif player_entered and not _en_cooldown:
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
	sonido_golpe.stream = ESPADA_GOLPE  # ✅ reutiliza nodo fijo
	sonido_golpe.play()
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
		sonido_enemigo.volume_db = 40.0
		sonido_enemigo.pitch_scale = 2.0
		sonido_enemigo.play()
		animation_player.play("dying")
		animation_player.animation_finished.connect(_on_dying_finished, CONNECT_ONE_SHOT)
		nav_agent.queue_free()
	elif !died:
		velocity += get_gravity()
		move_and_slide()

func _on_dying_finished(_anim: String) -> void:
	animation_player.pause()

	colision.shape.height = 0.5
	colision.shape.radius = 0.3
	colision.position.y = - 0.5
func puede_interactuar() -> bool:
	if died and item != null:
		return player_entered

	return false

func interactuar(_player):
	if _agregando:
		return
	_agregando = true
	_agregar.call_deferred(_player)

func _agregar(_player) -> void:
	if item == null:
		_agregando = false
		return

	var item_a_agregar = item
	item = null

	if await _player.inventario_controller.agregar_item(item_a_agregar):
		pass
	#colision.queue_free()
	area.queue_free()
	_agregando = false

func attack_behavior() -> void:
	if _atacando_cooldown:
		return

	_atacando_cooldown = true
	damage = int(randf_range(min_damage, max_damage))  # ✅ movido acá
	attack_dir = (player.global_position - global_position).normalized()
	attack_dir.y = 0

	animation_player.play("attack")
	animation_player.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)

func _on_attack_finished(anim: String) -> void:
	if anim != "attack":
		return
	animation_vector = Vector3.ZERO
	_en_cooldown = true
	animation_player.play("chase")
	get_tree().create_timer(3.0).timeout.connect(_on_cooldown_finished, CONNECT_ONE_SHOT)
	
func _on_cooldown_finished() -> void:
	_en_cooldown = false
	_atacando_cooldown = false
	var raycast = get_node_or_null("raycast_enemigo")  # ajustá el nombre
	if raycast:
		raycast.ya_golpeo = false
func _on_area_deteccion_body_entered(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		sonido_enemigo.stream = SONIDO_ENEMIGO
		sonido_enemigo.volume_db = -30.0
		sonido_enemigo.play()
		player_entered = true

func _on_area_deteccion_body_exited(body: Node3D) -> void:
	if body.is_in_group("jugador"):
		player_entered = false
