# ------------------------------------------------------------------
# FLECHA GUIA
# Busca el camino (con AStarGrid2D) desde Alex hasta el objetivo actual
# y muestra una flecha dorada junto a Alex que apunta por dónde ir.
# Cuando Alex está cerca del objetivo, la flecha se pone encima de él.
# ------------------------------------------------------------------
extends Node2D

const CELDA := MascaraCaminable.TAMANO_CELDA

@onready var flecha: Sprite2D = $Flecha

var astar := AStarGrid2D.new()
var alex: Node2D = null
var direccion := Vector2.RIGHT
var tiempo_busqueda := 0.0
var tiempo := 0.0
var cerca_del_objetivo := false


func _ready() -> void:
	crear_cuadricula()
	alex = get_tree().get_first_node_in_group("jugador") as Node2D


# Arma la cuadrícula de caminos a partir de mascara_caminable.gd
func crear_cuadricula() -> void:
	astar.region = Rect2i(0, 0, MascaraCaminable.ANCHO, MascaraCaminable.ALTO)
	astar.cell_size = Vector2(CELDA, CELDA)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()

	var datos := MascaraCaminable.cargar()
	for y in MascaraCaminable.ALTO:
		for x in MascaraCaminable.ANCHO:
			var i := y * MascaraCaminable.ANCHO + x
			var bit := (datos[i >> 3] >> (7 - (i & 7))) & 1
			if bit == 0:
				astar.set_point_solid(Vector2i(x, y), true)


func _process(delta: float) -> void:
	if alex == null or Juego.objetivo_posicion == Vector2.ZERO:
		flecha.visible = false
		return

	tiempo += delta
	tiempo_busqueda -= delta
	if tiempo_busqueda <= 0.0:
		tiempo_busqueda = 0.4
		buscar_direccion()

	flecha.visible = true
	var rebote := sin(tiempo * 6.0) * 2.0
	if cerca_del_objetivo:
		# Flecha encima del objetivo, apuntando hacia abajo
		flecha.global_position = Juego.objetivo_posicion + Vector2(0, -26 + rebote)
		flecha.rotation = PI / 2
	else:
		flecha.global_position = alex.global_position + Vector2(0, 4) + direccion * (24 + rebote)
		flecha.rotation = direccion.angle()


func buscar_direccion() -> void:
	var objetivo := Juego.objetivo_posicion
	cerca_del_objetivo = alex.global_position.distance_to(objetivo) < 70
	if cerca_del_objetivo:
		return

	var desde := celda_libre(alex.global_position + Vector2(0, 8))
	var hasta := celda_libre(objetivo)
	var camino := astar.get_id_path(desde, hasta)

	if camino.size() < 2:
		# Si no hay camino, apunta en línea recta
		direccion = (objetivo - alex.global_position).normalized()
		return

	# Mira unas celdas adelante para que la flecha no tiemble en las esquinas
	var siguiente: Vector2i = camino[min(10, camino.size() - 1)]
	var punto := Vector2(siguiente) * CELDA + Vector2(CELDA, CELDA) / 2.0
	direccion = (punto - alex.global_position).normalized()


# Convierte una posición a celda; si cae en algo bloqueado busca la libre más cercana
func celda_libre(posicion: Vector2) -> Vector2i:
	var base := Vector2i(posicion / CELDA)
	for radio in 8:
		for dy in range(-radio, radio + 1):
			for dx in range(-radio, radio + 1):
				var c := base + Vector2i(dx, dy)
				if astar.is_in_boundsv(c) and not astar.is_point_solid(c):
					return c
	return base
