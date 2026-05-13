@tool
extends Node3D

@export var textura: Texture2D:
	set(value):
		textura = value
		if is_inside_tree():
			recrear_sprites()

@export var radio := 2.0

@export var velocidad_espiral := 3.0

@export var curva_alpha := 2.0

@export var velocidad_avance := 3.0:
	set(value):
		velocidad_avance = value
		if is_inside_tree():
			recrear_sprites()

@export var tamanio := 0.5:
	set(value):
		tamanio = value
		if is_inside_tree():
			recrear_sprites()

@export var largo_estela := 6.0:
	set(value):
		largo_estela = value
		if is_inside_tree():
			recrear_sprites()

@export var cantidad := 8:
	set(value):
		cantidad = value
		if is_inside_tree():
			recrear_sprites()

@export var oleadas := 6:
	set(value):
		oleadas = value
		if is_inside_tree():
			recrear_sprites()

var sprites = []
var tiempos = []

func _ready():
	recrear_sprites()

func recrear_sprites():
	for grupo in sprites:
		for s in grupo:
			s.queue_free()
	sprites.clear()
	tiempos.clear()

	for o in oleadas:
		var grupo = []
		tiempos.append(float(o) / oleadas * largo_estela / velocidad_avance)
		for i in cantidad:
			var s = Sprite3D.new()
			s.texture = textura        # textura directo en el sprite
			s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			s.double_sided = true
			s.pixel_size = tamanio
			s.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
			add_child(s)
			grupo.append(s)
		sprites.append(grupo)
func _process(delta):
	for o in oleadas:
		tiempos[o] += delta
		var z = tiempos[o] * velocidad_avance
		var progreso = fmod(z, largo_estela) / largo_estela
		var r = radio * (1.0 - progreso)
		var alpha = 1.0 - pow(progreso, curva_alpha)
		
		# brillo va de 1.0 (lleno) a 0.0 (negro) con el progreso
		var brillo = 1.0 - progreso

		for i in cantidad:
			var angulo = (TAU / cantidad) * i + fmod(tiempos[o] * velocidad_espiral, TAU)
			sprites[o][i].position = Vector3(
				cos(angulo) * r,
				sin(angulo) * r,
				fmod(z, largo_estela)
			)
			sprites[o][i].modulate = Color(brillo, brillo, brillo, alpha)
