# ------------------------------------------------------------------
# PENSAMIENTO NEGATIVO (enemigo)
# Está escondido en la niebla y solo aparece cuando Alex se acerca
# (idea tomada del Leever del Zelda, pero por distancia).
# Mientras está visible dice frases negativas y persigue a Alex.
# Al vencerlo hay un destello de luz y aparece una frase positiva.
# Las frases están en scripts/frases.gd según el "tipo".
# ------------------------------------------------------------------
class_name Pensamiento
extends CharacterBody2D

const RUTA_RESPIRO := "res://escenas/objetos/respiro.tscn"
const RUTA_DESTELLO := "res://escenas/efectos/destello.tscn"

@export_enum("voz", "culpa", "aislamiento", "ansiedad") var tipo: String = "voz"
@export var color_mensaje := Color(0.85, 0.7, 1.0)
@export var vida := 2
@export var velocidad := 26.0
@export var radio_aparicion := 85.0
@export var radio_olvido := 170.0
# true = se mueve a saltos, como la ansiedad (idea del Tektite)
@export var se_mueve_a_saltos := false
@export_range(0, 100) var probabilidad_respiro := 35

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_danio: Area2D = $AreaDanio

var jugador: Alex = null
var mensajes: Array = []
var esta_visible := false
var esta_vencido := false
var posicion_inicial := Vector2.ZERO
var etiqueta: Label = null
var indice_mensaje := 0
var tiempo_mensaje := 0.0
var tiempo_salto := 0.0
var direccion_salto := Vector2.ZERO
var empuje := Vector2.ZERO


func _ready() -> void:
	add_to_group("enemigos")
	posicion_inicial = global_position
	modulate.a = 0.0
	area_danio.monitoring = false
	area_danio.monitorable = false
	animated_sprite_2d.play("default")
	jugador = get_tree().get_first_node_in_group("jugador") as Alex
	# Cada enemigo recibe las frases de su zona en un orden distinto
	mensajes = Frases.negativas(tipo)
	# La etiqueta se crea un frame después (la escena aún se está armando)
	call_deferred("crear_etiqueta")


func crear_etiqueta() -> void:
	etiqueta = Juego.crear_etiqueta_mundo("", color_mensaje)
	etiqueta.modulate.a = 0.0


func _physics_process(delta: float) -> void:
	if esta_vencido or jugador == null:
		return

	var distancia := global_position.distance_to(jugador.global_position)

	if not esta_visible and distancia < radio_aparicion:
		aparecer()
	elif esta_visible and distancia > radio_olvido:
		desaparecer()

	if esta_visible:
		perseguir(delta)
		revisar_contacto()
		actualizar_mensaje(delta)

	if etiqueta != null:
		etiqueta.position = global_position + Vector2(-etiqueta.size.x / 2.0, -26)


# ----------------------------------
# MOVIMIENTO
# ----------------------------------
func perseguir(delta: float) -> void:
	var hacia_jugador := (jugador.global_position - global_position).normalized()

	if se_mueve_a_saltos:
		tiempo_salto -= delta
		if tiempo_salto <= 0.0:
			tiempo_salto = randf_range(0.7, 1.2)
			direccion_salto = hacia_jugador.rotated(randf_range(-0.7, 0.7))
		# Se mueve rápido al inicio del salto y luego se queda quieto
		if tiempo_salto > 0.4:
			velocity = direccion_salto * velocidad * 3.2
		else:
			velocity = Vector2.ZERO
	else:
		velocity = hacia_jugador * velocidad

	velocity += empuje
	empuje = empuje.move_toward(Vector2.ZERO, 500.0 * delta)
	move_and_slide()

	if abs(velocity.x) > 1.0:
		animated_sprite_2d.flip_h = velocity.x < 0


func revisar_contacto() -> void:
	for cuerpo in area_danio.get_overlapping_bodies():
		if cuerpo is Alex:
			(cuerpo as Alex).recibir_danio(global_position)


# ----------------------------------
# APARECER / DESAPARECER EN LA NIEBLA
# ----------------------------------
func aparecer() -> void:
	esta_visible = true
	Audio.sonido("aparece", -8.0)
	area_danio.set_deferred("monitoring", true)
	area_danio.set_deferred("monitorable", true)
	tiempo_mensaje = 0.0

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6)
	if etiqueta != null:
		etiqueta.text = mensajes[indice_mensaje]
		tween.parallel().tween_property(etiqueta, "modulate:a", 1.0, 0.6)


func desaparecer() -> void:
	esta_visible = false
	velocity = Vector2.ZERO
	area_danio.set_deferred("monitoring", false)
	area_danio.set_deferred("monitorable", false)

	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	if etiqueta != null:
		tween.parallel().tween_property(etiqueta, "modulate:a", 0.0, 0.5)
	# Vuelve a esconderse en su lugar
	tween.tween_callback(func(): global_position = posicion_inicial)


func actualizar_mensaje(delta: float) -> void:
	tiempo_mensaje += delta
	if tiempo_mensaje >= 2.6 and etiqueta != null:
		tiempo_mensaje = 0.0
		indice_mensaje = (indice_mensaje + 1) % mensajes.size()
		etiqueta.text = mensajes[indice_mensaje]


# ----------------------------------
# RECIBIR GOLPE DE LA ESPADA
# ----------------------------------
func recibir_golpe(origen: Vector2) -> void:
	if esta_vencido or not esta_visible:
		return

	vida -= 1
	Audio.sonido("golpe")
	empuje = (global_position - origen).normalized() * 220.0

	var tween := create_tween()
	tween.tween_property(animated_sprite_2d, "modulate", Color(3, 3, 3), 0.05)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.15)

	if vida <= 0:
		vencer()


func vencer() -> void:
	esta_vencido = true
	Audio.sonido("enemigo_vencido")
	Juego.enemigos_vencidos += 1
	area_danio.set_deferred("monitoring", false)
	area_danio.set_deferred("monitorable", false)
	collision_shape_2d.set_deferred("disabled", true)

	# Destello de luz
	var destello := (load(RUTA_DESTELLO) as PackedScene).instantiate() as Node2D
	destello.global_position = global_position
	get_parent().call_deferred("add_child", destello)

	# Frase positiva que contradice al pensamiento
	Juego.texto_flotante(global_position, Frases.positiva(tipo), Color(1.0, 0.93, 0.7))
	soltar_respiro()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.4)
	tween.tween_property(self, "modulate", Color(3, 3, 3, 0), 0.4)
	if etiqueta != null:
		tween.tween_property(etiqueta, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)


# Igual que drop_random_item del Zelda
func soltar_respiro() -> void:
	if randi_range(1, 100) <= probabilidad_respiro:
		var respiro := (load(RUTA_RESPIRO) as PackedScene).instantiate() as Node2D
		respiro.global_position = global_position + Vector2(0, 6)
		get_parent().call_deferred("add_child", respiro)


func _exit_tree() -> void:
	if etiqueta != null and is_instance_valid(etiqueta):
		etiqueta.queue_free()
