extends Node3D

@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var light: OmniLight3D = $empty/SpotLight3D

func _is_visible_with_margin(camera: Camera3D, margin: float) -> bool:
	var planes = camera.get_frustum()
	for plane in planes:
		if plane.distance_to(global_position) > margin:
			return false
	return true

func _process(_delta):
	var camera = get_viewport().get_camera_3d()
	if camera == null:
		return
	
	var _is_visible = _is_visible_with_margin(camera, 2.0)
	particles.emitting = _is_visible
	light.visible = _is_visible
