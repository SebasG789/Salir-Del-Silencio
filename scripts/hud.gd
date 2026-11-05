# ------------------------------------------------------------------
# HUD: vida, fragmentos, objetivo, nombre de zona, pistas, diálogos
# (con opciones), mapa (M) y menú de pausa (Esc).
# Funciona aunque el juego esté en pausa (process_mode = Always).
# ------------------------------------------------------------------
class_name HUD
extends CanvasLayer

signal dialogo_terminado
signal opcion_elegida(indice: int)

# Las imágenes se cargan en _ready() con load() (no con preload) para que el
# proyecto abra bien la primera vez, antes de que Godot importe las imágenes.
var textura_corazones: Texture2D = null
var textura_fragmentos: Texture2D = null
const NOMBRES_FRAGMENTOS := ["La Voz", "El Apoyo", "La Esperanza"]
const TAMANO_MAPA := Vector2(2067, 761)

@onready var corazones: HBoxContainer = $BarraSuperior/Vida/Corazones
@onready var iconos_fragmentos: HBoxContainer = $BarraSuperior/Fragmentos/Iconos
@onready var texto_objetivo: Label = $Objetivo
@onready var banner_zona: VBoxContainer = $BannerZona
@onready var titulo_zona: Label = $BannerZona/Titulo
@onready var subtitulo_zona: Label = $BannerZona/Subtitulo
@onready var pista: Label = $Pista
@onready var dialogo: PanelContainer = $Dialogo
@onready var titulo_dialogo: Label = $Dialogo/Margen/VBox/Titulo
@onready var texto_dialogo: Label = $Dialogo/Margen/VBox/Texto
@onready var opciones: VBoxContainer = $Dialogo/Margen/VBox/Opciones
@onready var continuar: Label = $Dialogo/Margen/VBox/Continuar
@onready var mapa: PanelContainer = $Mapa
@onready var imagen_mapa: TextureRect = $Mapa/Margen/VBox/Imagen
@onready var marca_alex: ColorRect = $Mapa/Margen/VBox/Imagen/MarcaAlex
@onready var marca_objetivo: TextureRect = $Mapa/Margen/VBox/Imagen/MarcaObjetivo
@onready var pausa: PanelContainer = $Pausa
@onready var boton_continuar: Button = $Pausa/Margen/VBox/Continuar
@onready var instrucciones: Instrucciones = $Instrucciones
@onready var danio_rect: ColorRect = $Danio
@onready var fundido_rect: ColorRect = $Fundido

var lineas := PackedStringArray()
var indice := 0
var en_dialogo := false
var en_opciones := false
var tween_texto: Tween = null
var tween_banner: Tween = null
var energia_anterior := Juego.ENERGIA_MAXIMA


func _ready() -> void:
	Juego.hud = self
	textura_corazones = load("res://assets/sprites/corazon.png")
	textura_fragmentos = load("res://assets/sprites/fragmentos.png")
	crear_iconos()
	Juego.energia_cambio.connect(actualizar_energia)
	Juego.fragmentos_cambio.connect(actualizar_fragmentos)
	Juego.objetivo_cambio.connect(actualizar_objetivo)
	actualizar_energia(Juego.energia, Juego.ENERGIA_MAXIMA)
	actualizar_fragmentos(Juego.fragmentos)
	banner_zona.modulate.a = 0.0
	pista.visible = false
	dialogo.visible = false
	mapa.visible = false
	pausa.visible = false
	instrucciones.visible = false
	instrucciones.cerrado.connect(_on_instrucciones_cerrado)
	danio_rect.color.a = 0.0
	fundido_rect.color = Color(0, 0, 0, 1)
	fundido(Color(0, 0, 0, 0), 1.0)


func crear_iconos() -> void:
	for i in Juego.ENERGIA_MAXIMA:
		var icono := TextureRect.new()
		icono.texture = textura_corazon(true)
		icono.custom_minimum_size = Vector2(16, 16)
		icono.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		corazones.add_child(icono)

	for i in 3:
		var atlas := AtlasTexture.new()
		atlas.atlas = textura_fragmentos
		atlas.region = Rect2(i * 12, 0, 12, 16)
		var icono := TextureRect.new()
		icono.texture = atlas
		icono.custom_minimum_size = Vector2(12, 16)
		icono.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		iconos_fragmentos.add_child(icono)


func textura_corazon(lleno: bool) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = textura_corazones
	# corazon.png tiene 5 estados: 0 = vacío ... 4 = lleno (16x16 cada uno)
	atlas.region = Rect2(64 if lleno else 0, 0, 16, 16)
	return atlas


# ----------------------------------
# VIDA Y FRAGMENTOS
# ----------------------------------
func actualizar_energia(actual: int, _maximo: int) -> void:
	for i in corazones.get_child_count():
		var icono := corazones.get_child(i) as TextureRect
		icono.texture = textura_corazon(i < actual)

	# Pantalla roja cuando Alex pierde vida
	if actual < energia_anterior:
		var tween := create_tween()
		tween.tween_property(danio_rect, "color:a", 0.35, 0.05)
		tween.tween_property(danio_rect, "color:a", 0.0, 0.35)
	energia_anterior = actual


func actualizar_fragmentos(lista: Array) -> void:
	for i in iconos_fragmentos.get_child_count():
		var icono := iconos_fragmentos.get_child(i) as TextureRect
		var tiene: bool = lista.has(NOMBRES_FRAGMENTOS[i])
		# Los que faltan se ven como una silueta gris
		icono.modulate = Color(1, 1, 1, 1) if tiene else Color(0.45, 0.45, 0.6, 0.9)
		icono.self_modulate = Color(1, 1, 1, 1) if tiene else Color(0.5, 0.5, 0.5, 1)


func actualizar_objetivo(texto: String, _posicion: Vector2) -> void:
	texto_objetivo.text = "Objetivo: " + texto
	var tween := create_tween()
	tween.tween_property(texto_objetivo, "modulate", Color(1, 0.9, 0.5), 0.2)
	tween.tween_property(texto_objetivo, "modulate", Color.WHITE, 0.8)


# ----------------------------------
# NOMBRE DE LA ZONA
# ----------------------------------
func mostrar_zona(nombre: String, subtitulo: String) -> void:
	titulo_zona.text = nombre
	subtitulo_zona.text = subtitulo
	if tween_banner != null:
		tween_banner.kill()
	tween_banner = create_tween()
	tween_banner.tween_property(banner_zona, "modulate:a", 1.0, 0.6)
	tween_banner.tween_interval(2.2)
	tween_banner.tween_property(banner_zona, "modulate:a", 0.0, 0.8)


# ----------------------------------
# PISTAS ("E: hablar")
# ----------------------------------
func mostrar_pista(texto: String) -> void:
	pista.text = texto
	pista.visible = true


func ocultar_pista() -> void:
	pista.visible = false


# ----------------------------------
# DIALOGOS
# Uso:  await Juego.hud.mostrar_dialogo("Titulo", PackedStringArray(["linea 1", "linea 2"]))
# ----------------------------------
func mostrar_dialogo(titulo: String, nuevas_lineas: PackedStringArray) -> void:
	if nuevas_lineas.is_empty():
		return
	lineas = nuevas_lineas
	indice = 0
	en_dialogo = true
	titulo_dialogo.text = titulo
	opciones.visible = false
	continuar.visible = true
	dialogo.visible = true
	get_tree().paused = true
	mostrar_linea()
	await dialogo_terminado


func mostrar_linea() -> void:
	Audio.sonido("dialogo", -6.0)
	texto_dialogo.text = lineas[indice]
	texto_dialogo.visible_ratio = 0.0
	if tween_texto != null:
		tween_texto.kill()
	tween_texto = create_tween()
	tween_texto.tween_property(texto_dialogo, "visible_ratio", 1.0, lineas[indice].length() * 0.015)


func avanzar() -> void:
	# Si el texto aún se está escribiendo, se muestra completo
	if tween_texto != null and tween_texto.is_running():
		tween_texto.kill()
		texto_dialogo.visible_ratio = 1.0
		return

	indice += 1
	if indice >= lineas.size():
		cerrar_dialogo()
	else:
		mostrar_linea()


func cerrar_dialogo() -> void:
	en_dialogo = false
	dialogo.visible = false
	# Pequeña espera para que la misma tecla no ataque al cerrar
	await get_tree().create_timer(0.15).timeout
	if not en_dialogo and not en_opciones:
		get_tree().paused = false
	dialogo_terminado.emit()


# ----------------------------------
# PREGUNTAS CON OPCIONES
# Uso:  var respuesta := await Juego.hud.mostrar_opciones("Sam", "¿Te quedas?", PackedStringArray(["Sí", "No"]))
# Devuelve el número de la opción elegida (0, 1, 2...)
# ----------------------------------
func mostrar_opciones(titulo: String, pregunta: String, lista: PackedStringArray) -> int:
	en_opciones = true
	titulo_dialogo.text = titulo
	texto_dialogo.text = pregunta
	texto_dialogo.visible_ratio = 1.0
	continuar.visible = false
	dialogo.visible = true
	get_tree().paused = true

	for hijo in opciones.get_children():
		hijo.queue_free()
	for i in lista.size():
		var boton := Button.new()
		boton.text = "> " + lista[i]
		boton.alignment = HORIZONTAL_ALIGNMENT_LEFT
		boton.add_theme_font_size_override("font_size", 10)
		boton.pressed.connect(_on_opcion_pressed.bind(i))
		opciones.add_child(boton)
	opciones.visible = true

	# Esperamos un momento para que la tecla anterior no elija sin querer
	await get_tree().create_timer(0.2).timeout
	if opciones.get_child_count() > 0:
		(opciones.get_child(0) as Button).grab_focus()

	var elegida: int = await opcion_elegida

	en_opciones = false
	opciones.visible = false
	dialogo.visible = false
	await get_tree().create_timer(0.15).timeout
	if not en_dialogo and not en_opciones:
		get_tree().paused = false
	return elegida


func _on_opcion_pressed(i: int) -> void:
	if en_opciones:
		Audio.sonido("boton")
		opcion_elegida.emit(i)


# ----------------------------------
# TECLADO: diálogos, mapa (M) y pausa (Esc)
# ----------------------------------
func _unhandled_input(event: InputEvent) -> void:
	if en_dialogo:
		if event.is_action_pressed("ATACAR") or event.is_action_pressed("INTERACTUAR") or event.is_action_pressed("ui_accept"):
			get_viewport().set_input_as_handled()
			avanzar()
		return

	if en_opciones or instrucciones.visible:
		return

	if event.is_action_pressed("MAPA") and not pausa.visible:
		get_viewport().set_input_as_handled()
		alternar_mapa()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if mapa.visible:
			alternar_mapa()
		else:
			alternar_pausa()


# ----------------------------------
# MAPA
# ----------------------------------
func alternar_mapa() -> void:
	Audio.sonido("boton")
	mapa.visible = not mapa.visible
	get_tree().paused = mapa.visible
	if mapa.visible:
		var alex := get_tree().get_first_node_in_group("jugador") as Node2D
		var escala := imagen_mapa.custom_minimum_size / TAMANO_MAPA
		if alex != null:
			marca_alex.position = alex.global_position * escala - marca_alex.size / 2.0
		marca_objetivo.visible = Juego.objetivo_posicion != Vector2.ZERO
		marca_objetivo.position = Juego.objetivo_posicion * escala - marca_objetivo.size / 2.0
		var tween := create_tween().set_loops(3)
		tween.tween_property(marca_alex, "modulate:a", 0.2, 0.25)
		tween.tween_property(marca_alex, "modulate:a", 1.0, 0.25)


# ----------------------------------
# PAUSA
# ----------------------------------
func alternar_pausa() -> void:
	Audio.sonido("boton")
	pausa.visible = not pausa.visible
	get_tree().paused = pausa.visible
	if pausa.visible:
		boton_continuar.grab_focus()


func _on_continuar_pressed() -> void:
	alternar_pausa()


func _on_instrucciones_pressed() -> void:
	pausa.visible = false
	instrucciones.abrir()


func _on_instrucciones_cerrado() -> void:
	if get_tree().paused:
		pausa.visible = true
		boton_continuar.grab_focus()


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()


# ----------------------------------
# FUNDIDO DE PANTALLA
# ----------------------------------
func fundido(color_final: Color, duracion: float) -> void:
	var tween := create_tween()
	tween.tween_property(fundido_rect, "color", color_final, duracion)
	await tween.finished
