extends CharacterBody3D

@onready var inv_UI: Node = $Inventario_Controller/CanvasLayer/Inventario_UI
@onready var inventario_controller: Node = $Inventario_Controller
@onready var camera: Camera3D = $camara_controller/camara_player

@onready var footstep = $footstep
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var footstep_player: AudioStreamPlayer3D = $footstep
@onready var raycast: RayCast3D = $camara_controller/camara_player/raycast
@onready var raycast_arma: RayCast3D = $pivote/posicion_arma/sprite_arma/raycast_arma
@onready var shape = $CollisionShape3D.shape as CapsuleShape3D
@onready var collision = $CollisionShape3D
@onready var dialogo = $"../UI/dialogo"
@onready var texto_plano = $"../UI/texto_plano"
@onready var jugador_ui: CanvasLayer = $Jugador_UI

@export var stamina : float
@export var golpeando = false
@export var JUMP_VELOCITY = 3.5
@export var vida : float
@export var armadura : float

var stamina_agotada: bool = false
var inventario_abierto = false
var moving = false
var corriendo = false
var objeto_actual = null
var SPEED : float = 2.5
const mouse_sensitivity = 0.002
var pitch := 0.0  # rotación vertical acumulada
var debug_line: MeshInstance3D
var arma : Arma = null
var CONSTANTE_ARMADURA : float = 100
var damage : Vector2
var damage_arma : Vector2
var total_damage : Vector2
var footstep_sounds = [
	preload("uid://bcy7vwpq2v668"),
	preload("uid://dugv4k8tmfje3"),
	preload("uid://cj0w3fingavab")
]

func cambiar_pitch_swing():
	var sonido_arma: AudioStreamPlayer = $pivote/posicion_arma/sprite_arma/sonido_arma
	sonido_arma.pitch_scale = randf_range(0.7, 1.3)
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	total_damage.x = (damage.x + damage_arma.x)
	total_damage.y = (damage.y + damage_arma.y)
func recibir_damage(_damage):
	var reduccion = armadura / (armadura + CONSTANTE_ARMADURA)
	var daño_final = _damage * (1.0 - reduccion)
	vida -= int(daño_final)
	reaccion_ui()
	
func reaccion_ui():
	var texture = jugador_ui.get_node("blood_splash")
	texture.visible = true
	texture.modulate = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_interval(0.1)
	tween.tween_property(texture, "modulate:a", 0.0, 0.5).set_delay(1.0)
	tween.tween_callback(func(): texture.visible = false)
	
func _unhandled_input(event):
	if event.is_action_pressed("Inventario"):
		inventario_abierto = !inventario_abierto
		inv_UI.visible = inventario_abierto
		raycast.enabled = not inventario_abierto

		if inventario_abierto:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("interactuar"):
		if inventario_abierto:
			return

		if dialogo.visible:
			dialogo.visible = false
			dialogo.stop_text()
			return

		if objeto_actual and objeto_actual.has_method("interactuar"):
			objeto_actual.interactuar(self)

	if event is InputEventMouseMotion and not inventario_abierto:
		# Rotación horizontal (libre)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Acumular pitch (vertical)
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))

		# Aplicar rotación limitada
		camera.rotation.x = pitch


func _physics_process(delta):

	objeto_actual = null

	if raycast.is_colliding():
		var obj = raycast.get_collider()

		if is_instance_valid(obj) and not obj.has_method("puede_interactuar"):
			obj = obj.get_parent()

		if is_instance_valid(obj) \
		and obj.has_method("puede_interactuar") \
		and obj.puede_interactuar():
			objeto_actual = obj

	if Input.is_action_pressed("agacharse"):
		if shape.height > 1.05:  # solo lerp si no llegó al destino
			shape.height = lerp(shape.height, 1.0, 25 * delta)
			collision.position.y = lerp(collision.position.y, 1.28, 25 * delta)
	elif not test_move(global_transform, Vector3.UP * 0.5):
		if shape.height < 1.75:  # solo lerp si no llegó al destino
			shape.height = lerp(shape.height, 1.8, 15 * delta)
			collision.position.y = lerp(collision.position.y, 0.881, 25 * delta)
	if stamina <= 5:
		stamina_agotada = true
	elif stamina >= 25:
		stamina_agotada = false

	if Input.is_action_pressed("correr") and stamina > 5 and not stamina_agotada:
		SPEED = 4
		if moving:
			stamina -= delta * SPEED * 4
			corriendo = true
		else:
			corriendo = false
			if stamina < 40:
				stamina += delta * 2.0 * 1.5  # valor fijo, no depende de SPEED
	else:
		SPEED = 2.0
		corriendo = false
		if stamina < 40:
			stamina += delta * 2.0 * 1.5  # mismo valor fijo
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not inventario_abierto:
		velocity.y = JUMP_VELOCITY
		
	if inventario_abierto:
		if footstep.playing:
			footstep.stop()

		velocity += get_gravity() * delta

		if is_on_floor():
			velocity.x = 0
			velocity.z = 0

		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var forward = -camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var right = camera.global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var direction = (right * input_dir.x - forward * input_dir.y).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	moving = velocity.length_squared() > 0.01 and is_on_floor()

func _process(_delta):
	if objeto_actual and not dialogo.visible and not inventario_abierto:
		if objeto_actual.is_in_group("puertas"):
			if objeto_actual.abierta:
				texto_plano.show_text("(E) Cerrar")
			else:
				texto_plano.show_text("(E) Abrir")
		
		elif objeto_actual.is_in_group("hoja_papel"):
			texto_plano.show_text("(E) Leer")
			
		elif objeto_actual.is_in_group("silla"):
			texto_plano.show_text("(E) Investigar")
			
		elif objeto_actual.is_in_group("recogibles"):
			texto_plano.show_text("(E) Recoger")
		else:
			texto_plano.show_text("(E) Interactuar")

		texto_plano.visible = true
	else:
		texto_plano.ocultar()

		if dialogo.visible and objeto_actual == null:
			dialogo.stop_text()
	if vida <= 0:
		var go_screen = jugador_ui.get_node("game_over_screen")
		#tendra que frenar el mundo entero
		go_screen.visible = true
		return
	#sonido pies
	if moving:
		if not footstep_player.is_playing():
			footstep_player.stream = footstep_sounds.pick_random()
			footstep_player.play()
	else:
		if footstep_player.is_playing():
			footstep_player.stop()
	if corriendo:
		footstep_player.pitch_scale = 1
	else:
		footstep_player.pitch_scale = 0.56
