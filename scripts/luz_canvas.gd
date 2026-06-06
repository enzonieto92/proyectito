extends PointLight2D

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_method(
		func(e): energy = e,
		0.4,
		1.2,
		2
	).set_trans(Tween.TRANS_SINE)
	tween.tween_method(
		func(e): energy = e,
		1.2,
		0.4,
		2
	).set_trans(Tween.TRANS_SINE)
