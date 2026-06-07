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
@onready var camara_controller = $camara_controller
@onready var collision = $CollisionShape3D
@onready var col_caja: CollisionShape3D = $col_caja
@onready var footstep = $footstep
@onready var panel_blur: Control = get_tree().get_first_node_in_group("background_inventario")
@onready var luz_antorcha: Node3D = $pivote_secundaria/posicion_secundaria/luz_antorcha
@onready var sonido_stamina: AudioStreamPlayer3D = $sonido_stamina
@onready var efecto_magia = get_tree().get_first_node_in_group("efecto_magia")
var _efecto_activo_anterior: bool = false
@export var fov_normal: float = 75.0
@export var fov_zoom: float = 35.0
@export var zoom_velocidad: float = 4.0
@export var corrupcion : int
var instruccion : RichTextLabel
var corrupcion_max: int
var _timer_corrupcion: float = 0.0
const HIT_ENEMIGO = preload("uid://clxo03u4jxli7")
const VELOCIDAD_DESGASTE: float = 1.0
const JUMP_VELOCITY = 3.5
const HECHIZO_COOLDOWN = 3
var gasto_stamina_salto :float = 50.0
const mouse_sensitivity = 0.002
const SPEED_NORMAL: float = 1.2
const SPEED_CORRIENDO: float = 2.5
const SPEED_RALENTIZADO: float = 0.5
const STAMINA_REGEN_QUIETO: float = 45.0  # más rápido que STAMINA_REGEN normal
const STAMINA_AGOTAMIENTO: float = 15.0    # se agota al llegar aquí
const STAMINA_RECUPERACION: float = 40.0  # puede volver a correr desde aquí
var STAMINA_MAX_REGEN: float     # tope para regenerar
const STAMINA_COSTO_CORRER: float = 10.0   # multiplicador de gasto (delta * SPEED * esto)
const STAMINA_REGEN: float = 20.0   
const STAMINA_REGEN_AGOTADA_QUIETO: float = 10.0
const STAMINA_REGEN_AGOTADA_MOVING: float = 5.0  # muy lenta cuando se agotó
var rb_muerte: RigidBody3D
@export var stamina: float:
	set(value):
		if STAMINA_MAX_REGEN > 0.0:
			stamina = clamp(value, 0.0, STAMINA_MAX_REGEN)
		else:
			stamina = value
@export var golpeando = false
@export var recibiendo_damage = false
@export var vida_max: float
@export var armadura: float
@export var peso: float
@export var bloqueando = false
@export var ritual_completo: bool
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
var forzar_agachado := false
var lanzando_hechizo = false
var puede_correr: bool = false
var objeto_actual = null
var SPEED: float = 2.5
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
	instruccion = get_tree().get_first_node_in_group("texto_instruccion")
	corrupcion_max = corrupcion 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	STAMINA_MAX_REGEN = stamina 
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
	var damage_final = int(randf_range(_damage.x, _damage.y) * (1.0 - reduccion))
	if ralentizar:
		_aplicar_ralentizacion(1.5)
	animaciones.on_block_hit()
	if !bloqueando:
		camara_controller.shake(0.05, 0.5, 60.0)
		print("RECIBI DAMAGE")

		sonido_hit()
	vida -= damage_final
	recibiendo_damage = false
	
func sonido_hit():
	print("SONANDO HIT")
	var s := AudioStreamPlayer3D.new()
	get_tree().root.add_child(s)

	s.stream = preload("uid://clxo03u4jxli7")
	s.global_position = camera.global_position
	s.attenuation_model = AudioStreamPlayer3D.ATTENUATION_DISABLED
	s.volume_db = -10
	s.play()

	await s.finished
	print("TERMINO HIT")
	s.queue_free()
func _aplicar_ralentizacion(duracion: float):
	if _tween_ralentizacion != null and _tween_ralentizacion.is_running():
		_tween_ralentizacion.kill()

	ralentizado = true
	SPEED = SPEED_RALENTIZADO  # ← usar la constante, no hardcodear 0.5
	_timer_ralentizacion = get_tree().create_timer(duracion)
	await _timer_ralentizacion.timeout
	ralentizado = false
	SPEED = SPEED_NORMAL  # ← restaurar explícitamente al terminar
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
		if instruccion.visible:
			instruccion.ocultar()
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
		if ritual_completo and not inventario_abierto and puede_lanzar:
			if instruccion.visible:
				instruccion.ocultar()
			lanzar_hechizo()

	if event is InputEventMouseMotion and not inventario_abierto:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-50), deg_to_rad(50))
		camera.rotation.x = pitch
var puede_lanzar = true

func lanzar_hechizo():
		if not puede_lanzar:  # ← solo este chequeo
			return
		puede_lanzar = false
		await get_tree().create_timer(0.2).timeout
		corrupcion = max(0, corrupcion - 1)
		if corrupcion < 2:
			$sonido_latidos.play()
		efecto_magia.activar(6 - corrupcion, true)
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
		await get_tree().create_timer(HECHIZO_COOLDOWN).timeout
		while efecto_magia._activo:
			await get_tree().process_frame
		puede_lanzar = true
		if corrupcion <= 0:
			ralentizado = true
			SPEED = SPEED_RALENTIZADO
			camara_controller.shake(0.022, 8, 100.0)
			while corrupcion < 2:
				await get_tree().process_frame
			ralentizado = false
			SPEED = SPEED_NORMAL
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
	objeto_actual = null
	if raycast.is_colliding():
		var obj = raycast.get_collider()
		if is_instance_valid(obj) and not obj.has_method("puede_interactuar"):
			obj = obj.get_parent()
		if is_instance_valid(obj) and obj.has_method("puede_interactuar") and obj.puede_interactuar():
			objeto_actual = obj

	if Input.is_action_pressed("agacharse"):
		puede_correr = false
		forzar_agachado = true
		shape.height = lerp(shape.height, 0.75, 25 * delta)
		collision.position.y = lerp(collision.position.y, 1.28, 25 * delta)
	else:
		if forzar_agachado:
			var puede_pararse = true
			var offsets = [
				Vector3.ZERO,
				Vector3(0.2, 0, 0),
				Vector3(-0.2, 0, 0),
				Vector3(0, 0, 0.2),
				Vector3(0, 0, -0.2),
			]
			for offset in offsets:
				var t = global_transform
				t.origin += offset
				if test_move(t, Vector3.UP * 1.0):
					puede_pararse = false
					break
			if puede_pararse:
				forzar_agachado = false

		if forzar_agachado:
			shape.height = 0.75
			collision.position.y = 1.28
		else:
			if shape.height < 1.75:
				shape.height = lerp(shape.height, 1.8, 15 * delta)
				collision.position.y = lerp(collision.position.y, 0.881, 25 * delta)
	_actualizar_velocidad(delta)

	if Input.is_action_just_pressed("saltar") and is_on_floor() and not inventario_abierto and stamina > 30:
		velocity.y = JUMP_VELOCITY
		stamina -= gasto_stamina_salto
		actualizar_estado_stamina()
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
	_empujar_rigidos()
	moving = velocity.length_squared() > 0.01 and is_on_floor()

func _empujar_rigidos():
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var cuerpo = colision.get_collider()
		
		if cuerpo is RigidBody3D:
			# Solo empujar si el contacto es lateral, no desde abajo
			var normal = colision.get_normal()
			if normal.y < 0.7:  # si la normal apunta mucho hacia arriba, es el piso
				var direccion = velocity.normalized()
				var fuerza = 1.0
				direccion.y = 0  # ignorar eje Y
				cuerpo.apply_central_impulse(direccion * fuerza)
func _process(delta):
	if is_instance_valid(rb_muerte) and _vida_muerto:
		global_transform = rb_muerte.global_transform
	if not _vida_muerto and vida <= 0:
		_vida_muerto = true
		muerto = true
		animar_muerte()
		pantalla_muerte()
		return
	if muerto:
		return

	# regen corrupcion
	var efecto_activo = is_instance_valid(efecto_magia) and efecto_magia._activo
	if _efecto_activo_anterior and not efecto_activo:
		_timer_corrupcion = 0.0  # ← termino el efecto, resetear timer
	_efecto_activo_anterior = efecto_activo

	if corrupcion < corrupcion_max and not efecto_activo:
		_timer_corrupcion += delta
		if _timer_corrupcion >= 3.0:
			_timer_corrupcion = 0.0
			corrupcion += 1
			if corrupcion >= 2 and $sonido_latidos.playing:
				$sonido_latidos.stop()

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

	_actualizar_antorcha(delta)
	var fov_objetivo = fov_zoom if Input.is_action_pressed("zoom") else fov_normal
	camera.fov = lerp(camera.fov, fov_objetivo, zoom_velocidad * delta)
# -------------------------
# MUERTE
# -------------------------
func desequipar_items():
	arma = null
	luz_antorcha.visible = false
	secundaria = null
	inventario_controller.remover_equipado()
	
func animar_muerte() -> void:
	desequipar_items()
	muerto = true
	set_physics_process(false)
	# Guardar velocidad antes de frenarlo
	var velocidad_muerte = velocity

	# Limpiar estados de movimiento
	moving = false
	corriendo = false
	puede_correr = false
	forzar_agachado = false

	stop_footstep()

	# Resetear animaciones
	animaciones.resetear_estado()

	# Forzar salida de correr/caminar
	animaciones.movimiento_sm.travel("idle")

	velocity = Vector3.ZERO

	camara_controller.set_process(false)
	camara_controller.set_physics_process(false)

	animaciones.stop()
	animaciones.set_process(false)
	animaciones.set_physics_process(false)

	var rb = RigidBody3D.new()
	rb_muerte = rb

	var col_capsula = collision.duplicate()
	col_capsula.shape.height = 1.75
	var col_caja_copia = col_caja.duplicate()
	col_caja.disabled = false
	col_caja_copia.disabled = false
	rb.add_child(col_capsula)
	rb.add_child(col_caja_copia)

	get_tree().root.add_child(rb)

	rb.global_transform = camera.global_transform
	rb.add_collision_exception_with(self)

	rb.mass = 1

	# Heredar la velocidad real
	rb.linear_velocity = velocidad_muerte

	var atras = camera.global_transform.basis.z
	var costado = camera.global_transform.basis.x * (1.0 if randf() > 0.5 else -1.0)

	rb.apply_impulse(
		atras * randf_range(2.0, 4.0) +
		costado * randf_range(1.5, 3.0) +
		Vector3(0, randf_range(0.5, 1.5), 0)
	)

	rb.apply_torque_impulse(Vector3(
		randf_range(4.0, 6.0),
		randf_range(-1.5, 1.5),
		costado.x * randf_range(3.0, 5.0)
	))
func pantalla_muerte():
	muerto = true
	velocity = Vector3.ZERO
	stop_footstep()
	go_screen.visible = true
	const GAMEOVER = preload("uid://dxoideatl8kpi")
	animaciones.stop()
	await get_tree().create_timer(0.2).timeout
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
func _actualizar_antorcha(delta: float) -> void:
	if secundaria == null or not secundaria is Antorcha:
		return
	var antorcha := secundaria as Antorcha
	
	antorcha.durabilidad -= delta * VELOCIDAD_DESGASTE
	
	if antorcha.durabilidad <= 0:
		antorcha.durabilidad = 0
		inventario_controller.slot_secundaria.romper_arma()

func actualizar_estado_stamina():
	if stamina <= STAMINA_AGOTAMIENTO and not stamina_agotada:
		stamina_agotada = true
		sonido_stamina.play()

	elif stamina >= STAMINA_RECUPERACION and stamina_agotada:
		stamina_agotada = false
		sonido_stamina.stop()
func _actualizar_velocidad(delta: float) -> void:
	actualizar_estado_stamina()

	if Input.is_action_pressed("correr") and not ralentizado and not stamina_agotada and puede_correr and not forzar_agachado:
		SPEED = SPEED_CORRIENDO
		if moving:
			stamina -= delta * SPEED * STAMINA_COSTO_CORRER
			actualizar_estado_stamina()
			corriendo = true
		else:
			corriendo = false
			if stamina < STAMINA_MAX_REGEN:
				stamina += delta * STAMINA_REGEN_QUIETO
				
	else:
		SPEED = SPEED_RALENTIZADO if ralentizado else SPEED_NORMAL
		corriendo = false
		if stamina < STAMINA_MAX_REGEN:
			var en_piso = is_on_floor()
			var regen: float
			if stamina_agotada:
				regen = STAMINA_REGEN_AGOTADA_QUIETO if (not moving and en_piso) else STAMINA_REGEN_AGOTADA_MOVING
			elif not moving and en_piso:
				regen = STAMINA_REGEN_QUIETO
			else:
				regen = STAMINA_REGEN
			stamina += delta * regen
			actualizar_estado_stamina()
