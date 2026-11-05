# ------------------------------------------------------------------
# ALEX (jugador)
# Basado en FV_player del Zelda: movimiento en 4 direcciones y ataque
# con hitbox al frente. Alex lleva un farol (su luz en la niebla)
# y ataca con una ESPADA DE LUZ.
# ------------------------------------------------------------------
class_name Alex
extends CharacterBody2D

@export var velocidad := 72.0
@export var tiempo_invulnerable := 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var espada_hitbox: Area2D = $EspadaHitbox
@onready var tajo: AnimatedSprite2D = $Tajo
@onready var luz: PointLight2D = $Luz
@onready var camera_2d: Camera2D = $Camera2D

var puede_moverse := true
var esta_atacando := false
var invulnerable := false

# Hacia dónde mira Alex
var direccion_mirada := Vector2.DOWN

# Empujón cuando un pensamiento lo golpea
var empuje := Vector2.ZERO


func _ready() -> void:
	espada_hitbox.monitoring = false
	tajo.visible = false
	animated_sprite_2d.play("idle_down")


func _physics_process(delta: float) -> void:
	if not puede_moverse:
		velocity = Vector2.ZERO
		return

	# Hablar con personajes
	if Input.is_action_just_pressed("INTERACTUAR"):
		interactuar()

	# Atacar con la espada
	if Input.is_action_just_pressed("ATACAR") and not esta_atacando:
		atacar()

	var direccion := Input.get_vector("IZQUIERDA", "DERECHA", "ARRIBA", "ABAJO")
	if esta_atacando:
		direccion = Vector2.ZERO

	velocity = direccion * velocidad + empuje
	empuje = empuje.move_toward(Vector2.ZERO, 600.0 * delta)
	move_and_slide()

	if not esta_atacando:
		animar(direccion)


# ----------------------------------
# ANIMACIONES
# ----------------------------------
func nombre_direccion() -> String:
	if direccion_mirada == Vector2.UP:
		return "up"
	elif direccion_mirada == Vector2.LEFT:
		return "left"
	elif direccion_mirada == Vector2.RIGHT:
		return "right"
	return "down"


func animar(direccion: Vector2) -> void:
	if direccion == Vector2.ZERO:
		animated_sprite_2d.play("idle_" + nombre_direccion())
		return

	if abs(direccion.x) > abs(direccion.y):
		direccion_mirada = Vector2.RIGHT if direccion.x > 0 else Vector2.LEFT
	else:
		direccion_mirada = Vector2.DOWN if direccion.y > 0 else Vector2.UP

	animated_sprite_2d.play("walk_" + nombre_direccion())


# ----------------------------------
# ATAQUE CON LA ESPADA DE LUZ
# ----------------------------------
func atacar() -> void:
	esta_atacando = true
	Audio.sonido("espada", -4.0)
	animated_sprite_2d.play("attack_" + nombre_direccion())

	# El tajo y la zona de golpe se colocan hacia donde mira Alex
	espada_hitbox.position = direccion_mirada * 14
	espada_hitbox.monitoring = true
	tajo.position = direccion_mirada * 10 + Vector2(0, 2)
	tajo.rotation = direccion_mirada.angle()
	tajo.visible = true
	tajo.frame = 0
	tajo.play("tajo")

	# Esperamos dos frames de física para que el Area2D detecte lo que tiene encima
	await get_tree().physics_frame
	await get_tree().physics_frame

	for area in espada_hitbox.get_overlapping_areas():
		var enemigo := area.get_parent()
		if enemigo.is_in_group("enemigos") and enemigo.has_method("recibir_golpe"):
			enemigo.call("recibir_golpe", global_position)

	await get_tree().create_timer(0.22).timeout
	espada_hitbox.monitoring = false
	tajo.visible = false
	esta_atacando = false


# ----------------------------------
# HABLAR CON PERSONAJES
# ----------------------------------
func interactuar() -> void:
	for nodo in get_tree().get_nodes_in_group("interactuables"):
		var personaje := nodo as Node2D
		if personaje == null or not personaje.has_method("interactuar"):
			continue
		if global_position.distance_to(personaje.global_position) < 42:
			personaje.call("interactuar")
			return


# ----------------------------------
# RECIBIR DAÑO
# ----------------------------------
func recibir_danio(origen: Vector2) -> void:
	if invulnerable or not puede_moverse:
		return

	invulnerable = true
	Audio.sonido("danio")
	Juego.cambiar_energia(-1)
	empuje = (global_position - origen).normalized() * 180.0
	sacudir_camara()

	if Juego.energia <= 0:
		morir()
		return

	parpadear()
	await get_tree().create_timer(tiempo_invulnerable).timeout
	invulnerable = false


func parpadear() -> void:
	var tween := create_tween().set_loops(5)
	tween.tween_property(animated_sprite_2d, "modulate:a", 0.3, 0.1)
	tween.tween_property(animated_sprite_2d, "modulate:a", 1.0, 0.1)


func sacudir_camara() -> void:
	var tween := create_tween()
	for i in 4:
		tween.tween_property(camera_2d, "offset", Vector2(randf_range(-3, 3), randf_range(-3, 3)), 0.04)
	tween.tween_property(camera_2d, "offset", Vector2.ZERO, 0.04)


# Sin energía: no es un "game over", Alex vuelve al último lugar seguro
func morir() -> void:
	puede_moverse = false
	Juego.veces_sin_energia += 1
	animated_sprite_2d.modulate.a = 1.0

	await Juego.hud.mostrar_dialogo("Sin energía", PackedStringArray([
		"Alex se detiene. Todo pesa demasiado.",
		"Está bien parar y respirar. Descansar también es avanzar.",
		"Vuelves al último lugar seguro."
	]))

	global_position = Juego.punto_reaparicion
	camera_2d.reset_smoothing()
	empuje = Vector2.ZERO
	Juego.recuperar_energia()
	puede_moverse = true

	await get_tree().create_timer(1.0).timeout
	invulnerable = false
