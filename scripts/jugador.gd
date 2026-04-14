extends CharacterBody3D

@onready var inv_UI: Node = $Inventario_Controller/CanvasLayer/Inventario_UI
@onready var inventario_controller: Node = $Inventario_Controller
@onready var camera: Camera3D = $camara_player
@onready var footstep = $footstep
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var raycast: RayCast3D = $camara_player/raycast
@onready var raycast_arma: RayCast3D = $pivote/posicion_arma/sprite_arma/raycast_arma
@onready var shape = $CollisionShape3D.shape as CapsuleShape3D
@onready var collision = $CollisionShape3D
@onready var dialogo = $"../UI/dialogo"
@onready var texto_plano = $"../UI/texto_plano"

@export var golpeando = false
@export var JUMP_VELOCITY = 3.5
var inventario_abierto = false
var moving = false
var corriendo = false
var objeto_actual = null
var SPEED : float = 2.5
const mouse_sensitivity = 0.00002
var sobre_enemigo = false
var debug_line: MeshInstance3D

var footstep_sounds = [
	preload("uid://bcy7vwpq2v668"),
	preload("uid://dugv4k8tmfje3"),
	preload("uid://cj0w3fingavab")
]
@onready var footstep_player: AudioStreamPlayer3D = $footstep


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event.is_action_pressed("Inventario"):
		inventario_abierto = !inventario_abierto
		inv_UI.visible = inventario_abierto
		raycast.enabled = not inventario_abierto

		if inventario_abierto:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.is_action_just_pressed("atacar"):
		animation_player.play("atacar")

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
		rotate_y(-rad_to_deg(event.relative.x * mouse_sensitivity))
		camera.rotate_x(-rad_to_deg(event.relative.y * mouse_sensitivity))



func _physics_process(delta):

	objeto_actual = null

	if raycast.is_colliding():
		raycast.show()
		var obj = raycast.get_collider()
		if is_instance_valid(obj) and not obj.has_method("puede_interactuar"):
			obj = obj.get_parent()

		if is_instance_valid(obj) \
		and obj.has_method("puede_interactuar") \
		and obj.puede_interactuar():
			objeto_actual = obj

	if Input.is_action_pressed("agacharse"):
		shape.height = lerp(shape.height, 1.0, 25 * delta)
		collision.position.y = lerp(collision.position.y, 1.28,25 * delta)
	elif not test_move(global_transform, Vector3.UP * 0.5):
			shape.height = lerp(shape.height, 1.8, 15 * delta)
			collision.position.y = lerp(collision.position.y, 0.881, 25 * delta)
	if Input.is_action_pressed("correr"):
		SPEED = 4
		corriendo = true
	else:
		SPEED = 2.5
		corriendo = false

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
	var direction := (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	moving = velocity.length() > 0.1 and is_on_floor()

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
