extends CharacterBody3D

@onready var inventario_controller: Node = $Inventario_Controller/CanvasLayer/Inventario_UI
@onready var camera: Camera3D = $Camera3D
@onready var footstep = $footstep
@onready var raycast: RayCast3D = $Camera3D/raycast

var inventario_abierto = false
var moving = false

var steps = [
	preload("res://paso1.mp3"),
	preload("res://paso2.mp3"),
	preload("res://paso3.mp3"),
]

const SPEED = 2.5
@export var JUMP_VELOCITY = 3.5
const mouse_sensitivity = 0.00002


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):

	# Toggle inventario
	if event.is_action_pressed("Inventario"):
		inventario_abierto = !inventario_abierto
		inventario_controller.visible = inventario_abierto
		raycast.collide_with_bodies = not inventario_abierto

		if inventario_abierto:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	# Cámara
	if event is InputEventMouseMotion and not inventario_abierto:
		rotate_y(-rad_to_deg(event.relative.x * mouse_sensitivity))
		camera.rotate_x(-rad_to_deg(event.relative.y * mouse_sensitivity))


func _physics_process(delta: float) -> void:

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not inventario_abierto:
		velocity.y = JUMP_VELOCITY

	# Freeze total si el inventario está abierto
	if inventario_abierto:
		
		if footstep.playing:
			footstep.stop()
		velocity+= get_gravity() * delta
		if is_on_floor():  # ← solo frena si está en el piso
			velocity.x = 0
			velocity.z = 0

		move_and_slide()
		return
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta


	# Movimiento
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		moving = false

	move_and_slide()

	# Sonido de pasos
	if moving and is_on_floor():
		if not footstep.playing:
			footstep.stream = steps.pick_random()
			footstep.play()
	else:
		if footstep.playing:
			footstep.stop()
