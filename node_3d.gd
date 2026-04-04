extends CharacterBody3D

@onready var camera: Camera3D = $Camera3D
@onready var footstep = $"../CharacterBody3D/footstep"
var steps = [
	preload("res://paso1.mp3"),
	preload("res://paso2.mp3"),
	preload("res://paso3.mp3"),
]
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.00002
var moving = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event): 
	if event is InputEventMouseMotion:
		rotate_y(-rad_to_deg(event.relative.x * mouse_sensitivity))
		camera.rotate_x(-rad_to_deg(event.relative.y * mouse_sensitivity))
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if moving and is_on_floor():
		if not footstep.playing:
			footstep.stream = steps.pick_random()
			footstep.play()
	else:
		if footstep.playing:
			footstep.stop()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		moving = true	
	else:
		moving = false
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
