# ------------------------------------------------------------------
# JUEGO (Autoload / Singleton)
# Guarda el estado global de la partida: energía (vida), fragmentos,
# objetivo actual, punto de reaparición y resultado de la trivia.
# Se accede desde cualquier script escribiendo: Juego.algo
# ------------------------------------------------------------------
extends Node

signal energia_cambio(actual: int, maximo: int)
signal fragmentos_cambio(lista: Array)
signal objetivo_cambio(texto: String, posicion: Vector2)

const ENERGIA_MAXIMA := 5
const TOTAL_FRAGMENTOS := 3
const INICIO := Vector2(95, 570)

var energia: int = ENERGIA_MAXIMA
var fragmentos: Array = []
var punto_reaparicion: Vector2 = INICIO
var zona_actual: String = ""

# Sam solo entrega el fragmento si Alex acepta su compañía
var acepto_apoyo := false
# La Esperanza aparece solo después de acompañar a Nico en El Aislamiento
var ayudo_a_nico := false
# Vale (La Ansiedad) enseña a respirar; sin ella la salida no se abre
var ayudo_a_vale := false

# ----------------------------------
# EVALUACION (trivia inicial y final)
# ----------------------------------
# "inicial" antes de jugar, "final" después de salir del bosque
var modo_trivia := "inicial"
var puntaje_trivia := -1          # aciertos de la trivia inicial (-1 = no la hizo)
var puntaje_final := -1           # aciertos de la trivia final
var total_trivia := 0
var respuestas_inicial: Array = []   # true/false por pregunta
var respuestas_final: Array = []

# Datos de la partida (tiempo, enemigos vencidos y caídas)
var tiempo_inicio_ms := 0
var tiempo_juego_seg := 0
var enemigos_vencidos := 0
var veces_sin_energia := 0

# Objetivo actual (lo usan el HUD y la flecha guía)
var objetivo_texto := ""
var objetivo_posicion := Vector2.ZERO

# Lugares importantes: los fragmentos, Sam y la salida se registran solos
var lugares := {}

# Los fragmentos del mapa se registran aquí para poder activarlos por nombre
var fragmentos_en_mapa := {}

# El HUD se registra solo cuando aparece en la escena
var hud: HUD = null


# Se llama al comenzar una partida nueva
func reiniciar() -> void:
	energia = ENERGIA_MAXIMA
	fragmentos.clear()
	punto_reaparicion = INICIO
	zona_actual = ""
	acepto_apoyo = false
	ayudo_a_nico = false
	ayudo_a_vale = false
	tiempo_inicio_ms = Time.get_ticks_msec()
	tiempo_juego_seg = 0
	enemigos_vencidos = 0
	veces_sin_energia = 0
	energia_cambio.emit(energia, ENERGIA_MAXIMA)
	fragmentos_cambio.emit(fragmentos)
	actualizar_objetivo()


# ----------------------------------
# ENERGIA (VIDA)
# ----------------------------------
func cambiar_energia(cantidad: int) -> void:
	energia = clampi(energia + cantidad, 0, ENERGIA_MAXIMA)
	energia_cambio.emit(energia, ENERGIA_MAXIMA)


func recuperar_energia() -> void:
	energia = ENERGIA_MAXIMA
	energia_cambio.emit(energia, ENERGIA_MAXIMA)


# ----------------------------------
# FRAGMENTOS
# ----------------------------------
func agregar_fragmento(nombre: String) -> void:
	if not fragmentos.has(nombre):
		fragmentos.append(nombre)
		fragmentos_cambio.emit(fragmentos)
		actualizar_objetivo()


# Hace aparecer un fragmento escondido (lo usa Sam con "El Apoyo")
func activar_fragmento(nombre: String) -> void:
	var nodo = fragmentos_en_mapa.get(nombre)
	if nodo != null and is_instance_valid(nodo):
		nodo.activar()
		return
	# Respaldo: buscar el fragmento en la escena por su nombre
	for candidato in get_tree().get_nodes_in_group("fragmentos"):
		if candidato.get("nombre") == nombre:
			candidato.call("activar")
			return
	push_warning("No se encontró el fragmento: " + nombre)


# Se llama al llegar a la salida con los 3 fragmentos
func terminar_partida() -> void:
	tiempo_juego_seg = int((Time.get_ticks_msec() - tiempo_inicio_ms) / 1000.0)


# La salida se abre con los 3 fragmentos y después de ayudar a Vale
func puede_salir() -> bool:
	return tiene_todos() and ayudo_a_vale


func tiene_todos() -> bool:
	return fragmentos.size() >= TOTAL_FRAGMENTOS


# ----------------------------------
# OBJETIVO (lo que el jugador debe hacer ahora)
# ----------------------------------
func registrar_lugar(nombre: String, posicion: Vector2) -> void:
	lugares[nombre] = posicion


func actualizar_objetivo() -> void:
	var texto := ""
	var lugar := ""

	if not fragmentos.has("La Voz"):
		texto = "Encuentra el fragmento de La Voz (sube las escaleras al norte)"
		lugar = "La Voz"
	elif not fragmentos.has("El Apoyo"):
		if not acepto_apoyo:
			texto = "Cruza el Santuario y habla con Sam en El Apoyo (al este)"
			lugar = "Sam"
		else:
			texto = "Recoge el fragmento de El Apoyo junto a la fogata"
			lugar = "El Apoyo"
	elif not fragmentos.has("La Esperanza"):
		if not ayudo_a_nico:
			texto = "Baja a El Aislamiento (al sur del Santuario) y habla con Nico, que está solo en la niebla"
			lugar = "Nico"
		else:
			texto = "Busca el fragmento de La Esperanza (al sureste, cruzando el puente)"
			lugar = "La Esperanza"
	elif not ayudo_a_vale:
		texto = "Antes de salir, busca a Vale en La Ansiedad (al norte de El Apoyo)"
		lugar = "Vale"
	else:
		texto = "¡Tienes los 3 fragmentos y la calma! Ve a la salida (al noreste)"
		lugar = "Salida"

	objetivo_texto = texto
	objetivo_posicion = lugares.get(lugar, Vector2.ZERO)
	objetivo_cambio.emit(objetivo_texto, objetivo_posicion)


# ----------------------------------
# TEXTOS EN EL MUNDO
# Los textos van en una CanvasLayer aparte ("capa_textos") para que
# la niebla (CanvasModulate) no los oscurezca.
# ----------------------------------
func crear_etiqueta_mundo(texto: String, color: Color, tamano: int = 8) -> Label:
	var etiqueta := Label.new()
	etiqueta.text = texto
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.add_theme_font_size_override("font_size", tamano)
	etiqueta.add_theme_color_override("font_color", color)
	etiqueta.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	etiqueta.add_theme_constant_override("outline_size", 3)
	etiqueta.z_index = 50

	var capa := get_tree().get_first_node_in_group("capa_textos")
	if capa == null:
		capa = get_tree().current_scene
	capa.add_child(etiqueta)
	etiqueta.size = Vector2(200, 12)
	return etiqueta


# Texto que sube y desaparece (por ejemplo al vencer un pensamiento)
func texto_flotante(posicion: Vector2, texto: String, color: Color) -> void:
	var etiqueta := crear_etiqueta_mundo(texto, color)
	etiqueta.position = posicion - Vector2(etiqueta.size.x / 2.0, 30)

	var tween := etiqueta.create_tween()
	tween.set_parallel(true)
	tween.tween_property(etiqueta, "position:y", etiqueta.position.y - 20, 2.2)
	tween.tween_property(etiqueta, "modulate:a", 0.0, 1.2).set_delay(1.0)
	tween.chain().tween_callback(etiqueta.queue_free)
