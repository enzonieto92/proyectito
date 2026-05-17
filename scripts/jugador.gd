extends CharacterBody3D

@onready var inventario_ui: Control = get_tree().get_first_node_in_group("inventario_ui")
@onready var inventario_controller: Node = get_tree().get_first_node_in_group("inventario_controller")
@onready var dialogo: RichTextLabel = get_tree().get_first_node_in_group("dialogo")
@onready var texto_plano: RichTextLabel = get_tree().get_first_node_in_group("texto_plano")
@onready var jugador_ui: CanvasLayer = get_tree().get_first_node_in_group("jugador_ui")
@onready var blood_splash = jugador_ui.get_node("blood_splash")
@onready var go_screen = jugador_ui.get_node("game_over_screen")
@onready var raycast_arma: RayCast3D = $pivote/posicion_arma/sprite_arma/raycast_arma
@onready var raycast: RayCast3D = $camara_controller/camara_player/raycast
@onready var sonido_arma: AudioStreamPlayer = $pivote/posicion_arma/sprite_arma/sonido_arma
@onready var camera: Camera3D = $camara_controller/camara_player
@onready var shape = $CollisionShape3D.shape as CapsuleShape3D
@onready var footstep_player: AudioStreamPlayer3D = $footstep
@onready var animaciones: AnimationPlayer = $animaciones
@onready var hit_sound: AudioStreamPlayer3D = $hit_sound
@onready var camara_controller = $camara_controller
@onready var collision = $CollisionShape3D
@onready var footstep = $footstep
@onready var panel_blur: Control = get_tree().get_first_node_in_group("background_inventario")
@onready var luz_antorcha: Node3D = $pivote_secundaria/posicion_secundaria/luz_antorcha

const HIT_ENEMIGO = preload("uid://clxo03u4jxli7")

@export var stamina: float
@export var golpeando = false
@export var recibiendo_damage = false
@export var vida_max: float
@export var armadura: float
@export var peso: float
@export var bloqueando = false
var ritual_completo = false
var ralentizado: bool = false
var _timer_ralentizacion: SceneTreeTimer = null
var _tween_ralentizacion: Tween = null

var stamina_agotada: bool = false
var vida: float:
	set(value):
		vida = clamp(value, 0, vida_max)
		reaccion_ui()
var rebotar_golpe = false
var inventario_abierto: bool = false:
	set(value):
		inventario_abierto = value
		inventario_abierto_changed.emit(value)
var moving = false
var corriendo = false
var lanzando_hechizo = false
var puede_correr: bool = false
var objeto_actual = null
var SPEED: float = 2.5
const JUMP_VELOCITY = 3.5
const mouse_sensitivity = 0.002
var pitch := 0.0
var arma: Item = null
var secundaria: Item = null
var pechera: Pechera = null
var casco: Casco = null
var CONSTANTE_ARMADURA: float = 100
var damage: Vector2
var armadura_total: float = 0:
	set(value):
		if value != armadura_total:
			armadura_total = value
			print("armadura cambió a: ", value)
var damage_arma: Vector2
var total_damage: Vector2
var footstep_sounds = [
	preload("uid://bcy7vwpq2v668"),
	preload("uid://dugv4k8tmfje3"),
	preload("uid://cj0w3fingavab")
]

var _ultimo_objeto: Object = null
var _ultimo_texto: String = ""
var _vida_muerto := false
var muerto := false
signal inventario_abierto_changed(abierto: bool)
# -------------------------
# ARMADURA
# -------------------------
func romper_arma():
	inventario_controller.slot_mano_derecha.romper_arma()
func recalcular_armadura() -> void:
	var base = armadura
	base += pechera.armadura if pechera != null else 0
	base += casco.armadura if casco != null else 0
	base += secundaria.armadura if secundaria != null else 0
	if bloqueando:
		base += secundaria.armadura if secundaria != null else 0
		base += arma.armadura if arma != null and secundaria == null else 0
	armadura_total = base

# -------------------------
# BLOQUEO
# -------------------------

func activar_bloqueo():
	if not bloqueando:
		bloqueando = true
		if arma != null:
			raycast_arma.enabled = true
		recalcular_armadura()

func desactivar_bloqueo():
	if bloqueando:
		bloqueando = false
		if arma != null:
			raycast_arma.enabled = false
		recalcular_armadura()

# -------------------------
# INIT
# -------------------------

func cambiar_pitch_swing():
	sonido_arma.pitch_scale = randf_range(0.7, 1.3)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	total_damage.x = damage.x + damage_arma.x
	total_damage.y = damage.y + damage_arma.y
	vida = vida_max
	animaciones.play_spawn()

# -------------------------
# COMBATE
# -------------------------

func recibir_damage(_damage, ralentizar):
	recibiendo_damage = true
	var reduccion = armadura_total / (armadura_total + CONSTANTE_ARMADURA)
	var damage_final = int(_damage * (1.0 - reduccion))
	vida -= damage_final

	if ralentizar:
		_aplicar_ralentizacion(1.5)  # duración en segundos

	animaciones.on_block_hit()
	if !bloqueando:
		camara_controller.shake(0.05, 0.5, 60.0)
		hit_sound.play()
	recibiendo_damage = false

func _aplicar_ralentizacion(duracion: float):
	if _tween_ralentizacion != null and _tween_ralentizacion.is_running():
		_tween_ralentizacion.kill()

	ralentizado = true
	SPEED = 0.5
	_timer_ralentizacion = get_tree().create_timer(duracion)
	await _timer_ralentizacion.timeout
	ralentizado = false
# -------------------------
# UI
# -------------------------

func reaccion_ui():
	const FRAME_WIDTH = 144
	const DAMAGE_FRAMES = 5
	var atlas = blood_splash.texture as AtlasTexture
	var frame_index = clamp(int((1.0 - vida / vida_max) * DAMAGE_FRAMES), 0, DAMAGE_FRAMES - 1)
	atlas.region = Rect2(frame_index * FRAME_WIDTH, 0, FRAME_WIDTH, atlas.region.size.y)
	blood_splash.visible = frame_index > 0

# -------------------------
# INPUT
# -------------------------

func _unhandled_input(event):
	if event.is_action_pressed("Inventario"):
		if inventario_ui.visible:
			cerrar_inventario()
		else:
			inventario_ui.visible = true
			inventario_abierto = true
			raycast.enabled = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_animar_blur(true)  # 👈


	if event.is_action_pressed("interactuar"):
		if inventario_abierto:
			return
		if dialogo.visible:
			if dialogo.visible_characters >= dialogo.get_total_character_count():
				dialogo.visible = false
				dialogo.stop_text()
				return
			else:
				dialogo.visible_characters = dialogo.get_total_character_count()
				return
		if objeto_actual and objeto_actual.has_method("interactuar"):
			objeto_actual.interactuar(self)
	if event.is_action_pressed("lanzar_hechizo"):
		if ritual_completo and not inventario_abierto:
			lanzar_hechizo()
			get_tree().get_first_node_in_group("efecto_magia").activar(2)
		
	if event is InputEventMouseMotion and not inventario_abierto:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-50), deg_to_rad(50))
		camera.rotation.x = pitch
func lanzar_hechizo():	
	var hechizo_scene = preload("uid://ciho1ujuyxp5m")
	var hechizo = hechizo_scene.instantiate()
	get_tree().root.add_child(hechizo)
	hechizo.sonido_travel.play()
	
	# Dirección basada en la cámara, no en el jugador
	var adelante = -camera.global_transform.basis.z
	hechizo.global_position = global_position + adelante * 1.5 + Vector3.UP * 1.0
	hechizo.direccion = adelante
	
	# Rotación igual a la cámara
	hechizo.global_transform.basis = camera.global_transform.basis
func cerrar_inventario() -> void:
	inventario_ui.visible = false
	inventario_abierto = false
	raycast.enabled = true
	animaciones.resetear_estado()
	_animar_blur(false)  # 👈
	if not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _animar_blur(activar: bool) -> void:
	var material_bg = panel_blur.material as ShaderMaterial

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_method(
		func(v): material_bg.set_shader_parameter("blur_progress", v),
		0.0 if activar else 1.0,
		1.0 if activar else 0.0,
		0.3
	)

# -------------------------
# PHYSICS
# -------------------------

func _physics_process(delta):
	if animaciones.spawning:
		velocity += get_gravity() * delta
		move_and_slide()
		return
	if muerto:
		return

	objeto_actual = null
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		if is_instance_valid(obj) and not obj.has_method("puede_interactuar"):
			obj = obj.get_parent()
		if is_instance_valid(obj) and obj.has_method("puede_interactuar") and obj.puede_interactuar():
			objeto_actual = obj

	if Input.is_action_pressed("agacharse"):
		puede_correr = false
		if shape.height > 1.05:
			shape.height = lerp(shape.height, 0.2, 25 * delta)
			collision.position.y = lerp(collision.position.y, 1.28, 25 * delta)
	elif not test_move(global_transform, Vector3.UP * 0.5):
		if shape.height < 1.75:
			shape.height = lerp(shape.height, 1.8, 15 * delta)
			collision.position.y = lerp(collision.position.y, 0.881, 25 * delta)

	if stamina <= 5:
		stamina_agotada = true
	elif stamina >= 25:
		stamina_agotada = false

	if Input.is_action_pressed("correr") and not ralentizado and stamina > 5 and not stamina_agotada and puede_correr:
		SPEED = 2.5
		if moving:
			stamina -= delta * SPEED * 4
			corriendo = true
		else:
			corriendo = false
			if stamina < 40:
				stamina += delta * 3.0
	else:
		SPEED = 0.5 if ralentizado else 1.0
		corriendo = false
		if stamina < 40:
			stamina += delta * 3.0

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
		if not animaciones.animacion_en_curso:
			puede_correr = true
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	moving = velocity.length_squared() > 0.01 and is_on_floor()

# -------------------------
# PROCESS
# -------------------------

func _process(_delta):
	if objeto_actual and not dialogo.visible and not inventario_abierto:
		var nuevo_texto = _calcular_texto_interaccion()
		if objeto_actual != _ultimo_objeto or nuevo_texto != _ultimo_texto:
			_ultimo_objeto = objeto_actual
			_ultimo_texto = nuevo_texto
			texto_plano.show_text(_ultimo_texto)
		texto_plano.visible = true
	else:
		texto_plano.ocultar()
		_ultimo_objeto = null
		_ultimo_texto = ""
		if dialogo.visible and objeto_actual == null:
			dialogo.stop_text()
			dialogo.visible = false

	if not _vida_muerto and vida <= 0:
		_vida_muerto = true
		muerto = true
		pantalla_muerte()

# -------------------------
# MUERTE
# -------------------------

func pantalla_muerte():
	muerto = true
	velocity = Vector3.ZERO
	stop_footstep()
	animaciones.stop()
	go_screen.visible = true
	const GAMEOVER = preload("uid://dxoideatl8kpi")
	AudioManager.detener_todo()
	AudioManager.cambiar_ambiente(1, GAMEOVER, 1)
	AudioManager.fade_in(1, -20.0, 1)
	var tween = create_tween()
	tween.tween_property(go_screen, "modulate:a", 1.0, 4)
	tween.tween_property(go_screen, "modulate:v", 0.0, 4)
	tween.tween_callback(func():
		var fade = AudioManager.fade_out(1, 2)
		fade.tween_callback(func():
			AudioManager.detener_todo()
			get_tree().change_scene_to_file("res://escenas/escena_principal.tscn")
		)
	)

# -------------------------
# INTERACCION
# -------------------------

func _calcular_texto_interaccion() -> String:
	if objeto_actual.is_in_group("puertas"):
		return "(E) Cerrar" if objeto_actual.abierta else "(E) Abrir"
	elif objeto_actual.is_in_group("hoja_papel"):
		return "(E) Leer"
	elif objeto_actual.is_in_group("silla"):
		return "(E) Investigar"
	elif objeto_actual.is_in_group("recogibles"):
		return "(E) Agarrar"
	elif objeto_actual.is_in_group("estatua"):
		if objeto_actual.daga_colocada:
			return "(E) Cortarse"
		elif arma != null and arma.nombre == "Daga Ritual":
			return "(E) Colocar"
		else:
			return "(E) Inspeccionar"
	return "(E) Interactuar"

# -------------------------
# PASOS
# -------------------------

var last_step_time := 0.0
var step_cooldown := 0.2

func play_footstep():
	if not moving:
		return
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_step_time < step_cooldown:
		return
	last_step_time = now
	footstep_player.stream = footstep_sounds.pick_random()
	footstep_player.pitch_scale = 1.0 if corriendo else 0.56
	footstep_player.play()

func stop_footstep():
	if footstep_player.is_playing():
		footstep_player.stop()
